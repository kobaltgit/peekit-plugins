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
   - **Начальное рукопожатие**: при загрузке плагин отправляет `PEEKIT_READY` с интервалом (например, каждые 100 мс) до тех пор, пока хост не ответит сообщением `PEEKIT_INIT`.
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

### 3.4 Кнопка ручного переключения в шапке (UX Best Practice)

Рекомендуется размещать в шапке (toolbar) компактную кнопку переключения языка:
```html
<button class="btn btn-lang" id="btnToggleLang" title="Switch Language / Сменить язык">EN</button>
```
И повесить обработчик клика:
```javascript
document.getElementById('btnToggleLang').addEventListener('click', () => {
  applyLocale(currentLocale === 'ru' ? 'en' : 'ru');
});
```
Это даёт пользователю максимальный контроль, даже если настройки приложения не передались.

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
```�ойках PeekIt. Хост передаёт `locale` (BCP 47-тег, например `'ru'`, `'en'`, `'de'`) в `PEEKIT_INIT`.

---

## 4. Порядок создания и упаковки

```bash
# 1. Собрать пакет .pkit и обновить registry.json
node pack_plugin.cjs plugins/peekit-plugin-<slug>

# 2. Синхронизировать реестр и бинарники с каталогом маркетплейса
Copy-Item registry.json website/assets/registry.json
Copy-Item dist/<id>-<version>.pkit website/web/plugins/

# 3. Проверить целостность сайта маркетплейса
cd website
flutter analyze
flutter test
```

## 5. Интеграция в установленное приложение PeekIt (Windows)

Для тестирования «в бою»:
- Скопировать папку плагина в `D:\Peekit\plugins\<id>`
- Перезапустить `D:\Peekit\peekit.exe`
- Проверить лог `D:\Peekit\peekit.log` на наличие строки:
  `[PluginScanner] Loaded plugin '<Name>' v<Version> ([...]) enabled=true from ...`

## 6. Чек-лист тем и локализации перед публикацией

- [ ] Тёмная и светлая тема работают через CSS-переменные (`[data-theme="dark"]` / `[data-theme="light"]`).
- [ ] Нет хардкодных цветов в основных UI-элементах.
- [ ] Смена темы на лету (через `PEEKIT_THEME_CHANGED`) не требует перезагрузки плагина.
- [ ] Интерфейс переключается на язык, переданный в `PEEKIT_INIT` (`locale`).
- [ ] Присутствуют переводы минимум для `en` и `ru`.
- [ ] `<html lang="...">` обновляется при смене локали.
