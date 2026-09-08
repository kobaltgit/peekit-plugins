---
name: peekit-plugin-creator
description: Пошаговое руководство и правила для создания, упаковки в .pkit, тестирования и публикации плагинов в репозиторий peekit-plugins и маркетплейс PeekIt. Активируйте при создании нового плагина или обновлении существующего.
---

## 1. Главные правила разработки плагинов

1. **Self-Contained (Строгий Offline)**:
   - В плагине не должно быть внешних ссылок на CDN (`cdn.jsdelivr.net`, `unpkg.com`, `cdnjs.cloudflare.com` и т.д.).
   - Все зависимости (библиотеки JS, стили CSS, иконки SVG/Base64) должны находиться локально в архиве плагина.
   - **Рекомендация**: Однофайловая архитектура (`index.html`), где все скрипты и стили инлайнены, работает наиболее надёжно и быстро в изолированном WebView2 (`asset.localhost`).

2. **IPC Соглашения и протокол рукопожатия (`window.postMessage`)**:
   - **Начальное рукопожатие**: при загрузке плагин отправляет `PEEKIT_READY` с интервалом (например, каждые 100–300 мс) до тех пор, пока хост не ответит сообщением `PEEKIT_INIT`.
   - **Остановка интервала**: при получении `PEEKIT_INIT` интервал **обязательно очищается** (`clearInterval(readyInterval)`).
   - **Запрос данных**: плагин отправляет `{ type: 'PEEKIT_REQUEST_DATA' }` хосту.
   - **Получение данных**: хост присылает `{ type: 'PEEKIT_DATA_RESPONSE', payload: { data, error } }` или `{ data, error }`.
   - ⚠️ **КРИТИЧЕСКОЕ ПРАВИЛО**: **Никогда не отправляйте `PEEKIT_READY` в ответ на `PEEKIT_DATA_RESPONSE`!** Хост PeekIt интерпретирует `PEEKIT_READY` как перезагрузку iframe и заново отправляет `PEEKIT_INIT`, что приводит к бесконечному циклу ререндера и миганию окна.

3. **Схема манифеста (`manifest.json`)**:
   - `id`: обратная доменная нотация (`com.peekit.<slug>`).
   - `name`: понятное имя плагина.
   - `version`: semver (например, `1.0.0`).
   - `entry`: точка входа (`index.html`).
   - `supportedExtensions`: массив расширений в нижнем регистре с точкой, например `[".ipynb"]`, `[".ai", ".eps"]`.
   - `category`: одна из: `Graphics`, `Office`, `Media`, `Code`, `Archive`, `Utilities`.

4. **Канонический порядок выполнения скрипта (Zero-TDZ / Защита от ошибок хойстинга)**:
   - В JavaScript переменные, объявленные через `let` и `const`, находятся в Temporal Dead Zone (TDZ) до момента их инициализации.
   - Любая ошибка при инициализации или преждевременный вызов функции приводит к тихому падению скрипта ещё **до того**, как плагин успеет отправить `PEEKIT_READY`.
   - Код внутри прикладного `<script>` должен строго следовать порядку:
     ```text
     1. Объявление переменных состояния (currentTheme, currentLocale, currentData, readyInterval)
     2. Движок темы (applyTheme, слушатель matchMedia)
     3. Движок локализации (словарь I18N, helper t(), функция applyLocale)
     4. Слушатель IPC сообщений хоста (window.addEventListener('message', ...))
     5. Обработчики кликов интерфейса (#btnToggleLang, #btnToggleTheme, тулбар)
     6. Первоначальный вызов applyTheme(currentTheme) и applyLocale(currentLocale)
     7. Старт интервала рукопожатия (readyInterval = setInterval(...) с отправкой PEEKIT_READY)
     ```

---

## 2. Методика определения и смены темы оформления

Плагин **обязан** корректно подстраиваться под тему PeekIt — как при начальной загрузке, так и при её переключении «на лету». Это включает поддержку трёх режимов: светлого (`light`), тёмного (`dark`) и системного (`system`).

### 2.1 Источники данных темы в PeekIt

В объекте `payload` события `PEEKIT_INIT` и `PEEKIT_THEME_CHANGED` тема может передаваться в разных полях в зависимости от версии хоста:
1. `payload.isDark` (boolean: `true` / `false`).
2. `payload.theme` (строка: `'dark'`, `'light'` или `'system'`).
3. `payload.mode` (строка: `'dark'` / `'light'`).
4. `payload.settings?.theme` (строка из конфига приложения).
5. `payload.accentColor` или `payload.settings?.accentColor` (hex-код акцентного цвета, например `#F37626`).

### 2.2 Разрешение системной темы (`system`)

Если хост передал `'system'` (или тема не задана):
- Проверяем медиа-запрос ОС: `window.matchMedia('(prefers-color-scheme: dark)').matches`.
- Обязательно подписываемся на событие изменения темы ОС через `matchMedia.addEventListener('change')`, чтобы плагин автоматически менял цвета, когда пользователь переключает тему в Windows.

### 2.3 Готовый модуль `applyTheme`

```javascript
let isSystemTheme = false;

function applyTheme(themeInput) {
  let isDark = true;
  let accentColor = null;

  if (themeInput && typeof themeInput === 'object') {
    if (typeof themeInput.isDark === 'boolean') {
      isDark = themeInput.isDark;
    } else if (typeof themeInput.theme === 'string') {
      const t = themeInput.theme.toLowerCase();
      if (t === 'system') {
        isSystemTheme = true;
        isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      } else {
        isSystemTheme = false;
        isDark = t !== 'light';
      }
    } else if (typeof themeInput.mode === 'string') {
      isDark = themeInput.mode.toLowerCase() !== 'light';
    } else if (themeInput.settings && typeof themeInput.settings.theme === 'string') {
      const t = themeInput.settings.theme.toLowerCase();
      if (t === 'system') {
        isSystemTheme = true;
        isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      } else {
        isSystemTheme = false;
        isDark = t !== 'light';
      }
    }
    accentColor = themeInput.accentColor || themeInput.settings?.accentColor;
  } else if (typeof themeInput === 'string') {
    const t = themeInput.toLowerCase();
    if (t === 'system') {
      isSystemTheme = true;
      isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    } else {
      isSystemTheme = false;
      isDark = t !== 'light';
    }
  }

  // Применяем атрибут data-theme и классы на <body>
  document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
  if (isDark) {
    document.body.classList.remove('light-theme');
    document.body.classList.add('dark-theme');
  } else {
    document.body.classList.remove('dark-theme');
    document.body.classList.add('light-theme');
  }

  // Акцентный цвет
  if (accentColor) {
    document.documentElement.style.setProperty('--accent', accentColor);
  }
}

// Слушатель системной темы ОС
if (window.matchMedia) {
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (isSystemTheme) {
      applyTheme(e.matches ? 'dark' : 'light');
    }
  });
}
```

### 2.4 CSS-структура токенов темы

```css
/* Тёмная тема по умолчанию */
:root, [data-theme="dark"] {
  --bg-main:       #0d1117;
  --bg-surface:    #161b22;
  --bg-card:       #21262d;
  --bg-card-hover: #30363d;
  --border-color:  rgba(255, 255, 255, 0.12);
  --text-main:     #f0f6fc;
  --text-muted:    #8b949e;
  --accent:        #58a6ff;
}

/* Светлая тема */
[data-theme="light"] {
  --bg-main:       #f6f8fa;
  --bg-surface:    #ffffff;
  --bg-card:       #f3f4f6;
  --bg-card-hover: #e5e7eb;
  --border-color:  rgba(0, 0, 0, 0.12);
  --text-main:     #1f2328;
  --text-muted:    #656d76;
  --accent:        #0969da;
}
```

> **Правило**: Все элементы интерфейса должны использовать исключительно CSS-переменные (`var(--...)`), чтобы переключение темы происходило мгновенно и без артефактов нечитаемого текста.

---

## 3. Методика определения и интернационализации языка (i18n)

Плагин **обязан** поддерживать язык приложения. Если пользователь переключил язык PeekIt на английский, плагин должен отображаться на английском, а если на русский — на русском.

### 3.1 Важная особенность PeekIt: ключи `"language"` и `"locale"`

В конфигурационном файле PeekIt (`config.json`) язык пользователя хранится в параметре:
```json
"language": "en"  // или "ru"
```
При отправке `PEEKIT_INIT` или события смены языка хост может передать язык под разными именами:
- `payload.language`
- `payload.locale`
- `payload.lang`
- `payload.settings?.language`
- `payload.settings?.locale`

**ОШИБКА**: Проверять только `payload.locale`. Если проверить только `locale`, значение окажется `undefined`, и плагин останется на языке по умолчанию.
**ПРАВИЛЬНО**: Извлекать язык с каскадной проверкой:
```javascript
const langVal = payload.language || payload.locale || payload.lang ||
                payload.settings?.language || payload.settings?.locale || payload.settings?.lang;
```

### 3.2 Каскадный выбор языка и приоритеты

Язык интерфейса определяется в следующем порядке приоритета:
1. Язык из настроек PeekIt (`langVal` из `PEEKIT_INIT` или `PEEKIT_LANGUAGE_CHANGED`).
2. Сохранённый выбор пользователя в `localStorage.getItem('peekit_<slug>_lang')`.
3. Язык системы `navigator.language` (если начинается на `'ru'` → `'ru'`, иначе `'en'`).
4. Fallback: `'en'`.

### 3.3 Полная реализация модуля локализации

```javascript
const I18N = {
  ru: {
    loading: 'Загрузка...',
    waiting: 'Ожидание данных от приложения PeekIt',
    errorTitle: 'Не удалось прочитать файл',
    searchPlaceholder: 'Поиск...',
    filterAll: 'Все',
    copied: 'Скопировано в буфер обмена',
    langToggleTitle: 'Сменить язык (EN / RU)'
  },
  en: {
    loading: 'Loading...',
    waiting: 'Waiting for data from PeekIt application',
    errorTitle: 'Failed to read file',
    searchPlaceholder: 'Search...',
    filterAll: 'All',
    copied: 'Copied to clipboard',
    langToggleTitle: 'Switch language (EN / RU)'
  }
};

// Инициализация из localStorage или fallback
let currentLocale = localStorage.getItem('peekit_myplugin_lang') || 
                    (navigator.language && navigator.language.startsWith('ru') ? 'ru' : 'en');

function t(key) {
  return (I18N[currentLocale] || I18N.en)[key] || key;
}

function applyLocale(locale) {
  if (!locale) return;
  currentLocale = locale.slice(0, 2).toLowerCase();
  if (!I18N[currentLocale]) currentLocale = 'en';
  
  // Сохраняем в localStorage
  localStorage.setItem('peekit_myplugin_lang', currentLocale);
  document.documentElement.setAttribute('lang', currentLocale);

  // Кнопка-переключатель в шапке (если есть)
  const toggleBtn = document.getElementById('btnToggleLang');
  if (toggleBtn) {
    toggleBtn.textContent = currentLocale.toUpperCase();
    toggleBtn.title = t('langToggleTitle');
  }

  // Обновление текстовых узлов с data-i18n
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (key && t(key)) el.textContent = t(key);
  });

  // Обновление всплывающих подсказок с data-i18n-title
  document.querySelectorAll('[data-i18n-title]').forEach(el => {
    const key = el.getAttribute('data-i18n-title');
    if (key && t(key)) el.title = t(key);
  });

  // Обновление плейсхолдеров
  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (key && t(key)) el.placeholder = t(key);
  });

  // Если данные уже отрендерены, перерисовываем с новым языком
  if (typeof renderContent === 'function' && currentData) {
    renderContent(currentData);
  }
}

// ⚠️ ОБЯЗАТЕЛЬНО: Применить локаль немедленно при старте скрипта,
// чтобы статический HTML не мигал на языке по умолчанию до прихода IPC!
applyLocale(currentLocale);
```

### 3.4 Кнопка ручного переключения в шапке и двусторонняя синхронизация (Bi-directional IPC)

Рекомендуется размещать в шапке (toolbar) компактную кнопку переключения языка:
```html
<button class="btn btn-lang" id="btnToggleLang" title="Switch Language / Сменить язык">EN</button>
```
Обработчик клика должен не только менять внутреннее состояние плагина, но и **уведомлять родительское окно (хост PeekIt)** о смене языка:
```javascript
document.getElementById('btnToggleLang').addEventListener('click', () => {
  const nextLocale = currentLocale === 'ru' ? 'en' : 'ru';
  applyLocale(nextLocale);
  // Двусторонний IPC: уведомляем хост PeekIt
  if (window.parent && window.parent !== window) {
    window.parent.postMessage({
      type: 'PEEKIT_LANGUAGE_CHANGED',
      payload: { locale: nextLocale, language: nextLocale }
    }, '*');
  }
});
```

### 3.5 Обработка IPC событий языка и темы

```javascript
window.addEventListener('message', (event) => {
  const msg = event.data;
  if (!msg || typeof msg !== 'object') return;

  switch (msg.type) {
    case 'PEEKIT_INIT': {
      if (readyInterval) {
        clearInterval(readyInterval);
        readyInterval = null;
      }
      const payload = msg.payload || msg;

      // 1. Определение языка
      const langVal = payload.language || payload.locale || payload.lang || 
                      payload.settings?.language || payload.settings?.locale || payload.settings?.lang;
      if (langVal) {
        applyLocale(langVal);
      } else {
        applyLocale(currentLocale);
      }

      // 2. Определение темы
      applyTheme(payload);

      // 3. Запрос данных файла
      window.parent.postMessage({ type: 'PEEKIT_REQUEST_DATA' }, '*');
      break;
    }

    case 'PEEKIT_THEME_CHANGED': {
      applyTheme(msg.payload || msg);
      break;
    }

    case 'PEEKIT_LANGUAGE_CHANGED':
    case 'PEEKIT_LOCALE_CHANGED': {
      const payload = msg.payload || msg;
      const langVal = payload.language || payload.locale || payload.lang || 
                      (typeof payload === 'string' ? payload : null);
      if (langVal) {
        applyLocale(langVal);
      }
      break;
    }

    case 'PEEKIT_DATA_RESPONSE': {
      // Рендерим полученные данные
      // ВНИМАНИЕ: НЕ отправлять здесь PEEKIT_READY!
      break;
    }
  }
});
```

### 3.6 Глубокая локализация интерфейса (Deep Visual I18N)

Интернационализация не должна ограничиваться статическими заголовками. В плагине **не должно оставаться видимых строк на одном языке**:
1. **Вложенные текстовые узлы внутри кнопок тулбара**:
   - Например: `<button id="btnLayers"><span>▦</span> <span id="btnLayersText">Слои</span></button>`
   - При смене языка текст внутри `#btnLayersText` должен явно переводиться (`Слои` ⇄ `Layers`).
2. **Динамические бейджи, счетчики и статус-теги**:
   - Например, плагин PSD отображает количество слоев: `12 слоёв` / `12 layers`.
   - Плагин EPS отображает тип превью: `Вектор` ⇄ `Vector`, `Растр` ⇄ `Raster`.
3. **Заголовки выезжающих панелей и дроверов**:
   - Заголовок панели слоев: `Слои (12)` ⇄ `Layers (12)`.
4. **Всплывающие подсказки (tooltip / title)**:
   - Кнопки зума, масштаба, скачивания должны менять атрибут `title` через `data-i18n-title`.
5. **Динамический перерендер**:
   - В функции `applyLocale(locale)` обязательно обновляйте все видимые бейджи или повторно вызывайте `renderContent(currentData)`, если контент уже отображен.

---

## 4. Безопасная интеграция сторонних библиотек (Vendor Bundling)

Если плагин использует крупные сторонние библиотеки (например, `ag-psd`, `Three.js`, `Leaflet`, `PDF.js`, `sql.js`, `utif`):
1. **Порядок тегов в `index.html`**:
   - Сначала подключайте вендорные библиотеки (`<script src="vendor.js">` или инлайненный код вендора).
   - Лишь затем подключайте прикладной скрипт плагина.
2. **Изоляция глобальных объектов**:
   - Вендорный код не должен перезаписывать или ломать `window.parent`, `window.postMessage` или `navigator`.
   - Если вендорная библиотека обращается к `navigator.platform`, `navigator.appVersion` или `document.currentScript`, убедитесь, что в коде нет жестких предположений об окружении.
3. **Защита от отсутствия WebGL / WebAssembly**:
   - В плагинах с 3D или WASM всегда делайте fallback и отображайте понятное сообщение об ошибке пользователю на текущем языке.

---

## 5. Обязательное предрелизное тестирование (`test_plugins.cjs` / `npm test`)

Перед любой сборкой `.pkit` и коммитом в репозиторий **обязательно** запускается автоматизированный тестовый комплекс:

```bash
npm test
# или напрямую:
node test_plugins.cjs
```

### 5.1 Что проверяет автоматизированный тест

Комплекс проверяет все плагины по 6 ключевым критериям:
1. **Manifest Schema**:
   - Корректность `id` (`com.peekit.<slug>`).
   - Наличие обязательных полей: `name`, `version` (строгий semver), `entry`, `supportedExtensions`.
   - Реальное существование файла точки входа (`entry`).
2. **Strict Offline & Security**:
   - Сканирует все файлы плагина на наличие запрещенных сетевых паттернов:
     - Внешние CDN-скрипты (`<script src="https://...">`)
     - Внешние стили и шрифты (`<link href="https://...">`)
     - Внешние `<iframe>`
     - Удаленные сетевые запросы (`fetch('https://...')`, `XMLHttpRequest`, `WebSocket`).
3. **V8 Syntax Compilation (`vm.Script`)**:
   - Извлекает все `<script>` блоки и компилирует их через движок V8 без выполнения.
   - Гарантирует отсутствие синтаксических ошибок, незакрытых скобок и битых литералов шаблонов.
4. **Runtime Lifecycle & Handshake**:
   - Эмулирует запуск плагина в виртуальном DOM-окружении (WebView2 mock).
   - Проверяет, что плагин отправляет `PEEKIT_READY` родительскому окну.
   - Проверяет реакцию на `PEEKIT_INIT` (корректная очистка интервала рукопожатия).
5. **Theme Engine**:
   - Эмулирует отправку `PEEKIT_THEME_CHANGED` для `light` и `dark` тем, проверяет отсутствие исключений при смене темы на лету.
6. **Localization Engine**:
   - Проверяет наличие кнопки `#btnToggleLang`.
   - Эмулирует клик по `#btnToggleLang` (проверяет переключение локали).
   - Проверяет реакцию на `PEEKIT_LANGUAGE_CHANGED` от хоста (`ru` и `en`).

### 5.2 Критерий допуска к сборке

Сборка пакетов плагинов разрешена **только при 100% прохождении тестов** (статус `OK` и `ALL 20 PLUGINS PASSED PRE-PRODUCTION VERIFICATION`).

---

## 6. Порядок создания, упаковки и публикации

```bash
# 1. Запустить автоматизированные тесты всех плагинов
npm test

# 2. Собрать пакеты .pkit, обновить registry.json и скопировать на сайт маркетплейса
npm run pack
# (эквивалентно: node pack_plugin.cjs --all --update-registry --copy-to-website)

# 3. Синхронизировать с локально установленным приложением PeekIt (Windows)
Copy-Item -Recurse -Force plugins/* D:\Peekit\plugins\

# 4. Проверить сайт маркетплейса
cd website
flutter analyze
flutter test
```

## 7. Чек-лист проверки плагина перед релизом

- [ ] `npm test` завершается с кодом 0 (зеленый отчет без ошибок).
- [ ] Все зависимости строго локальные (Self-Contained / Offline).
- [ ] Соблюден канонический порядок выполнения скрипта (Zero-TDZ).
- [ ] Тёмная и светлая тема работают через CSS-переменные (`[data-theme="dark"]` / `[data-theme="light"]`).
- [ ] Смена темы на лету (`PEEKIT_THEME_CHANGED`) работает без перезагрузки страницы.
- [ ] В интерфейсе нет непереведенных видимых строк, кнопок, вложенных span или динамических счетчиков.
- [ ] Кнопка `#btnToggleLang` переключает язык и отправляет `PEEKIT_LANGUAGE_CHANGED` хосту.
- [ ] В `manifest.json` инкрементирована версия при внесении изменений.
- [ ] Плагин проверен в установленном `D:\Peekit\peekit.exe` с реальными файлами.
