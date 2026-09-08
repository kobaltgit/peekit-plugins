# Быстрый старт: Создание первого плагина за 10 минут

В этом руководстве мы с нуля создадим полноценный плагин для предварительного просмотра векторных файлов **SVG** с поддержкой тёмной/светлой темы, переключением языка (RU/EN), масштабированием и защитой от ошибок инициализации.

---

## Шаг 1. Подготовка окружения

Убедитесь, что у вас установлен **Node.js 18+**.  
Клонируйте репозиторий и установите локальные зависимости:

```bash
git clone https://github.com/kobaltgit/peekit-plugins.git
cd peekit-plugins
npm install
```

---

## Шаг 2. Создание структуры плагина

Создайте папку для плагина внутри каталога `plugins/` с префиксом `peekit-plugin-`:

```text
plugins/peekit-plugin-svg-demo/
├── manifest.json
└── index.html
```

> [!TIP]
> **Рекомендация архитектуры (Self-Contained Single-File):**  
> В изолированном WebView2 наиболее надёжно и быстро работает монолитная структура: HTML, стили CSS и логика JavaScript объединены в одном файле `index.html`. Это обеспечивает мгновенный холодный запуск (< 30 мс) и исключает проблемы с путями к ассетам.

---

## Шаг 3. Заполнение манифеста (`manifest.json`)

Создайте файл `plugins/peekit-plugin-svg-demo/manifest.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/kobaltgit/peekit-plugins/main/plugin-schema.json",
  "id": "com.peekit.svg-demo",
  "name": "SVG Vector Viewer",
  "version": "1.0.0",
  "author": "Your Name",
  "description": "Быстрый рендеринг векторных SVG-изображений с масштабированием и ночной темой",
  "category": "Graphics",
  "supportedExtensions": [".svg"],
  "extensions": [".svg"],
  "entry": "index.html",
  "min_peekit_version": "1.0.0",
  "default_dimensions": {
    "width": 960,
    "height": 680
  }
}
```

> [!IMPORTANT]
> - Поле `id` **обязано** начинаться с префикса `com.peekit.` (иначе не пройдут тесты `npm test`).
> - Поле `supportedExtensions` обязательно для тестового раннера, а `extensions` — для валидации по схеме `plugin-schema.json`.
> - Все расширения указываются в нижнем регистре с точкой.

---

## Шаг 4. Реализация интерфейса и логики (`index.html`)

Создайте файл `plugins/peekit-plugin-svg-demo/index.html`.  
Код оформлен с соблюдением канонического порядка исполнения скрипта (**Zero-TDZ**), стандартов **Fluent Design** и встроенной двуязычной локализацией (**I18N**):

```html
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>SVG Vector Viewer</title>
  <style>
    /* Fluent Design CSS Tokens */
    :root, [data-theme="dark"] {
      --bg-main: #0d1117;
      --bg-surface: #161b22;
      --bg-card: #21262d;
      --border-color: rgba(255, 255, 255, 0.12);
      --text-main: #f0f6fc;
      --text-muted: #8b949e;
      --accent: #58a6ff;
    }
    [data-theme="light"] {
      --bg-main: #f6f8fa;
      --bg-surface: #ffffff;
      --bg-card: #f3f4f6;
      --border-color: rgba(0, 0, 0, 0.12);
      --text-main: #1f2328;
      --text-muted: #656d76;
      --accent: #0969da;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg-main);
      color: var(--text-main);
      font-family: "Segoe UI Variable Text", system-ui, sans-serif;
      height: 100vh;
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }
    /* Header / Toolbar */
    #toolbar {
      height: 44px;
      background: var(--bg-surface);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      align-items: center;
      padding: 0 16px;
      gap: 12px;
      user-select: none;
    }
    #docTitle {
      font-size: 13px;
      font-weight: 600;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .badge {
      font-size: 11px;
      background: var(--bg-card);
      padding: 2px 8px;
      border-radius: 12px;
      color: var(--text-muted);
      border: 1px solid var(--border-color);
    }
    .spacer { flex: 1; }
    .btn {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      color: var(--text-main);
      border-radius: 6px;
      padding: 4px 10px;
      font-size: 12px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 4px;
      transition: background 0.15s;
    }
    .btn:hover { background: var(--border-color); }
    /* Viewport */
    #viewport {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: auto;
      position: relative;
    }
    #svgContainer svg {
      max-width: 90vw;
      max-height: calc(100vh - 80px);
      display: block;
    }
    #statusOverlay {
      position: absolute;
      font-size: 13px;
      color: var(--text-muted);
    }
  </style>
</head>
<body>

  <div id="toolbar">
    <span id="docTitle" data-i18n="loading">Загрузка...</span>
    <span class="badge" id="infoBadge">SVG</span>
    <div class="spacer"></div>
    <button class="btn" id="btnToggleLang" data-i18n-title="langToggleTitle" title="Сменить язык (EN / RU)">RU</button>
  </div>

  <div id="viewport">
    <div id="statusOverlay" data-i18n="waiting">Ожидание данных от приложения PeekIt</div>
    <div id="svgContainer"></div>
  </div>

  <script>
    // 1. Словарь локализации (I18N)
    const I18N = {
      ru: {
        loading: 'Загрузка...',
        waiting: 'Ожидание данных от приложения PeekIt',
        error: 'Не удалось распарсить SVG-файл',
        langToggleTitle: 'Сменить язык (EN / RU)'
      },
      en: {
        loading: 'Loading...',
        waiting: 'Waiting for data from PeekIt application',
        error: 'Failed to parse SVG file',
        langToggleTitle: 'Switch language (EN / RU)'
      }
    };

    // 2. Начальное состояние
    let currentLocale = (navigator.language && navigator.language.startsWith('ru')) ? 'ru' : 'en';
    let readyInterval = null;

    function t(key) {
      return (I18N[currentLocale] || I18N.en)[key] || key;
    }

    // 3. Управление языком
    function applyLocale(locale) {
      if (!locale) return;
      currentLocale = locale.slice(0, 2).toLowerCase();
      if (!I18N[currentLocale]) currentLocale = 'en';

      document.documentElement.setAttribute('lang', currentLocale);
      const btn = document.getElementById('btnToggleLang');
      if (btn) {
        btn.textContent = currentLocale.toUpperCase();
        btn.title = t('langToggleTitle');
      }

      document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (key && t(key)) el.textContent = t(key);
      });
      document.querySelectorAll('[data-i18n-title]').forEach(el => {
        const key = el.getAttribute('data-i18n-title');
        if (key && t(key)) el.title = t(key);
      });
    }

    // 4. Управление темой
    function applyTheme(isDark) {
      document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
    }

    // 5. Обработчик клика переключения языка
    document.getElementById('btnToggleLang').addEventListener('click', () => {
      const nextLocale = currentLocale === 'ru' ? 'en' : 'ru';
      applyLocale(nextLocale);
      // Уведомляем хост PeekIt о смене языка
      if (window.parent && window.parent !== window) {
        window.parent.postMessage({
          type: 'PEEKIT_LANGUAGE_CHANGED',
          payload: { language: nextLocale, locale: nextLocale }
        }, '*');
      }
    });

    // 6. Слушатель входящих IPC-сообщений
    window.addEventListener('message', (event) => {
      const msg = event.data;
      if (!msg || typeof msg !== 'object') return;

      switch (msg.type) {
        case 'PEEKIT_INIT': {
          // Обязательно гасим интервал PEEKIT_READY
          if (readyInterval) {
            clearInterval(readyInterval);
            readyInterval = null;
          }
          const p = msg.payload || {};
          if (p.language || p.locale) applyLocale(p.language || p.locale);
          applyTheme(p.isDark !== undefined ? p.isDark : p.theme !== 'light');
          
          // Запрашиваем данные файла
          window.parent.postMessage({ type: 'PEEKIT_REQUEST_DATA' }, '*');
          break;
        }

        case 'PEEKIT_DATA_RESPONSE': {
          const p = msg.payload || {};
          const status = document.getElementById('statusOverlay');
          const container = document.getElementById('svgContainer');
          const title = document.getElementById('docTitle');

          try {
            status.style.display = 'none';
            title.textContent = p.name || 'vector.svg';

            const rawContent = p.data || p.content;
            let svgString = typeof rawContent === 'string'
              ? rawContent
              : new TextDecoder().decode(rawContent);

            container.innerHTML = svgString;

            // Оповещаем хост о деталях заголовка
            window.parent.postMessage({
              type: 'SET_TITLE',
              payload: { title: `${p.name} (${(p.size / 1024).toFixed(1)} КБ)` }
            }, '*');
          } catch (err) {
            status.style.display = 'block';
            status.textContent = t('error') + ': ' + err.message;
            window.parent.postMessage({
              type: 'PEEKIT_ERROR',
              payload: { message: err.message }
            }, '*');
          }
          break;
        }

        case 'PEEKIT_THEME_CHANGED': {
          const p = msg.payload || {};
          applyTheme(p.isDark !== undefined ? p.isDark : p.theme !== 'light');
          break;
        }

        case 'PEEKIT_LANGUAGE_CHANGED':
        case 'PEEKIT_LOCALE_CHANGED': {
          const p = msg.payload || {};
          applyLocale(p.language || p.locale);
          break;
        }
      }
    });

    // 7. Начальная инициализация локали и старт рукопожатия
    applyLocale(currentLocale);
    readyInterval = setInterval(() => {
      window.parent.postMessage({ type: 'PEEKIT_READY' }, '*');
    }, 200);
  </script>
</body>
</html>
```

---

## Шаг 5. Локальная проверка в браузере (Mock Host)

Для быстрой отладки без запуска десктопного приложения откройте файл [`template/mock-host.html`](file:///d:/Projects/active/peekit-plugins/template/mock-host.html) в браузере:
1. В выпадающем списке **Плагин** выберите готовый плагин или пункт *«Свой путь к index.html...»*.
2. В поле пути укажите относительный путь к файлу точки входа вашего плагина:
   ```text
   ../plugins/peekit-plugin-svg-demo/index.html
   ```
3. Нажмите **🔄 Перезагрузить**. Плагин отобразится во фрейме.
4. Нажмите **Выберите файл** и укажите любой тестовый `.svg` файл с вашего диска для проверки отображения.
5. Проверьте реакцию на кнопки **Тема** и **Язык**, а также панель журналов обмена IPC справа.

---

## Шаг 6. Автоматическое тестирование (`npm test`)

Перед упаковкой обязательно проверьте плагин предрелизным тестовым раннером:

```bash
# Проверить только ваш плагин:
node test_plugins.cjs plugins/peekit-plugin-svg-demo

# Или запустить полную проверку всего репозитория:
npm test
```

Тест автоматически проверит манифест, отсутствие внешних запросов к сети, синтаксис скриптов в V8, цикл рукопожатия, переключение тем и полноту локализации.

---

## Шаг 7. Сборка пакета `.pkit`

Соберите готовый пакет плагина:

```bash
# Упаковать плагин в папку dist/:
node pack_plugin.cjs plugins/peekit-plugin-svg-demo

# Или обновить весь каталог и реестр registry.json:
npm run pack
```

В каталоге `dist/` будет сгенерирован готовый архив: `com.peekit.svg-demo-1.0.0.pkit` с вычисленной контрольной суммой SHA-256.  
Плагин готов к релизу и отправке в Pull Request!
