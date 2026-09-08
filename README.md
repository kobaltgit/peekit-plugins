<p align="center">
  <img src="website/web/icons/Icon-192.png" width="96" height="96" alt="PeekIt Plugins Logo" />
  <h1 align="center">🧩 PeekIt Plugins Ecosystem</h1>
  <strong>Официальный реестр, маркетплейс и SDK плагинов предварительного просмотра для PeekIt</strong><br/>
  <em>Official plugin registry, marketplace, and SDK for PeekIt quick preview</em>
</p>

<p align="center">
  <a href="https://kobaltgit.github.io/peekit-plugins/"><img src="https://img.shields.io/badge/Marketplace-Live%20Catalog-02569B.svg?logo=flutter" alt="Live Marketplace" /></a>
  <a href="https://github.com/kobaltgit/peekit"><img src="https://img.shields.io/badge/Host%20App-PeekIt%20v1.3+-38bdf8.svg?logo=windows" alt="Host App" /></a>
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg?logo=windows" alt="Windows 10/11" />
  <a href="PLUGIN_DEVELOPMENT_GUIDE.md"><img src="https://img.shields.io/badge/Format-.pkit%20(ZIP%20%2B%20Manifest)-brightgreen.svg" alt="Format .pkit" /></a>
  <a href="SECURITY.md"><img src="https://img.shields.io/badge/Sandbox-WebView2%20IFrame-orange.svg" alt="Sandbox" /></a>
  <img src="https://img.shields.io/badge/Ecosystem-Kobalt%20Tools-blueviolet.svg" alt="Kobalt Tools" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License" /></a>
</p>

<p align="center">
  <a href="#-о-проекте">🇷🇺 Русский</a> • <a href="#-about-the-project">🇬🇧 English</a> • <a href="#-экосистема-kobalt-tools">🌐 Экосистема</a>
</p>

---

## 🇷🇺 О проекте

**PeekIt Plugins** — официальный репозиторий экосистемы плагинов расширения для **[PeekIt](https://github.com/kobaltgit/peekit)**, ультрабыстрого инструмента предварительного просмотра файлов по клавише **Space (Пробел)** в Windows 10 & 11, входящего в семейство системных утилит **Kobalt Tools** ([StashIt](https://github.com/kobaltgit/StashIt), [MiniBin](https://github.com/kobaltgit/minibin), [Undoit](https://github.com/kobaltgit/undoit), [PolyShift](https://github.com/kobaltgit/polyshift), [PeekIt](https://github.com/kobaltgit/peekit)).

Плагины PeekIt представляют собой легковесные автономные веб-приложения (HTML5, JS, CSS, WebGL, WASM), исполняемые внутри изолированных контейнеров без прямого доступа к операционной системе.

### ⚡ Сравнение архитектуры плагинов

| Параметр | Плагины PeekIt (`.pkit`) | Нативные DLL-плагины | Electron / Отдельные процессы |
| :--- | :--- | :--- | :--- |
| **Изоляция и безопасность** | **WebView2 IFrame Sandbox** | Отсутствует (краш ломает хост) | Изоляция на уровне ОС |
| **Оверхед по памяти** | **0 МБ в фоне (загрузка по запросу)** | Занимает память хост-процесса | > 100–150 МБ на каждый процесс |
| **Стек разработки** | **HTML5 / JS / CSS / WASM / WebGL** | C++ / C# / Win32 | Node.js / Chromium |
| **Формат пакета** | **`.pkit` (ZIP + Manifest + SHA-256)** | `.dll` | `.exe` / `.node` |
| **Сетевой доступ** | **Полностью изолирован (100% Offline)** | Неограничен | Неограничен |
| **Установка** | **В 1 клик через веб-каталог или drag-and-drop** | Ручное копирование в System32 | Сложный инсталлятор |

### 🎯 Ключевые возможности

- 🛡️ **Безопасная песочница:** Плагины исполняются внутри `<iframe sandbox="allow-scripts">` без доступа к файловой системе, реестру и сети хоста.
- ⚡ **Нулевой оверхед (0 MB Idle):** Плагин активируется только в момент нажатия Пробела на поддерживаемом файле и моментально выгружается из памяти при закрытии окна.
- 🚀 **Нативный RPC-протокол:** Быстрый двусторонний обмен данными через `window.postMessage` с передачей бинарных данных (`ArrayBuffer`) без дублирования памяти.
- 🌐 **100% Автономность:** Все плагины полностью самодостаточны (self-contained) и функционируют без подключения к сети Интернет.
- 🤖 **Встроенный AI-агент для разработки:** Полная интеграция с Google Antigravity — субагент и навыки автоматизируют создание, сборку и тестирование плагинов.

### 📦 Каталог официальных плагинов

| Плагин | Идентификатор | Поддерживаемые форматы | Описание |
| :--- | :--- | :--- | :--- |
| **🎨 Font Viewer** | `com.peekit.font-viewer` | `.ttf`, `.otf`, `.woff`, `.woff2` | Предпросмотр шрифтов, кастомные панграммы, таблица глифов Unicode, санитайзер OpenType |
| **🧊 3D Model Viewer** | `com.peekit.3d-viewer` | `.stl`, `.obj`, `.gltf`, `.glb`, `.ply` | Аппаратный 3D-вьюпорт (Three.js), вращение 360°, сетка каркаса, материалы и полигоны |
| **📄 Word Document Viewer** | `com.peekit.docx-viewer` | `.docx`, `.doc` | Просмотр документов Word: рендеринг страниц A4, таблицы, изображения, ночной режим |
| **📊 Spreadsheet Viewer** | `com.peekit.sheet-viewer` | `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods` | Сетка Excel с формулами, переключение вкладок книги, живой поиск и фильтрация |
| **📽️ Presentation Viewer** | `com.peekit.slides-viewer` | `.pptx`, `.ppt` | Слайд-шоу PowerPoint, листание стрелками клавиатуры, боковая панель миниатюр слайдов |
| **🖌️ Adobe Illustrator Viewer** | `com.peekit.ai-viewer` | `.ai` | Векторный рендеринг иллюстраций, артборды, масштабирование и шахматная подложка |
| **🖼️ Adobe Photoshop Viewer** | `com.peekit.psd-viewer` | `.psd` | Превью файлов Photoshop: композитный рендер, древо слоев, разрешение и альфа-канал |

---

## 🇬🇧 About the Project

**PeekIt Plugins** is the official ecosystem repository for **[PeekIt](https://github.com/kobaltgit/peekit)**, an ultra-fast quick preview tool for Windows 10 & 11 activated via the **Space** key, and a core member of the **Kobalt Tools** system utility suite ([StashIt](https://github.com/kobaltgit/StashIt), [MiniBin](https://github.com/kobaltgit/minibin), [Undoit](https://github.com/kobaltgit/undoit), [PolyShift](https://github.com/kobaltgit/polyshift), [PeekIt](https://github.com/kobaltgit/peekit)).

PeekIt plugins are lightweight, standalone web applications (HTML5, JS, CSS, WebGL, WASM) running in isolated sandbox containers without direct operating system access.

### ⚡ Plugin Architecture Comparison

| Metric / Parameter | PeekIt Plugins (`.pkit`) | Native DLL Plugins | Electron / Out-of-Process Viewers |
| :--- | :--- | :--- | :--- |
| **Sandbox & Security** | **WebView2 IFrame Sandbox** | None (crashes take down the app) | OS process isolation |
| **Idle Memory Overhead** | **0 MB (on-demand activation)** | Permanently consumes host RAM | > 100–150 MB per running process |
| **Development Stack** | **HTML5 / JS / CSS / WASM / WebGL** | C++ / C# / Win32 | Node.js / Chromium |
| **Package Format** | **`.pkit` (ZIP + Manifest + SHA-256)** | `.dll` | `.exe` / `.node` |
| **Network Access** | **Completely Blocked (100% Offline)** | Unrestricted | Unrestricted |
| **Installation** | **1-click via Marketplace or Drag & Drop** | Manual file copying to system dirs | Heavy multi-step installer |

### 🎯 Core Features

- 🛡️ **Strict Sandbox Security:** Plugins execute inside `<iframe sandbox="allow-scripts">` without file system, registry, or network access.
- ⚡ **Zero Background Overhead (0 MB Idle):** Activated strictly when the Space key is pressed for a matching file format, releasing memory instantly upon window closure.
- 🚀 **Native RPC Protocol:** Fast duplex communication via `window.postMessage`, passing zero-copy binary buffers (`ArrayBuffer`).
- 🌐 **100% Offline & Private:** Fully self-contained packages requiring no internet connection or external CDN requests.
- 🤖 **Built-in AI Assistant:** Deep integration with Google Antigravity — automated scaffolding, packing, and validation via subagent and custom skills.

### 📦 Official Plugins Catalog

| Plugin | Identifier | Supported Extensions | Description |
| :--- | :--- | :--- | :--- |
| **🎨 Font Viewer** | `com.peekit.font-viewer` | `.ttf`, `.otf`, `.woff`, `.woff2` | Interactive typography preview, custom pangrams, Unicode glyph map, OpenType sanitizer |
| **🧊 3D Model Viewer** | `com.peekit.3d-viewer` | `.stl`, `.obj`, `.gltf`, `.glb`, `.ply` | Hardware 3D viewport (Three.js), 360° turntable, wireframe toggle, materials & polygon stats |
| **📄 Word Document Viewer** | `com.peekit.docx-viewer` | `.docx`, `.doc` | Native Word document reader: formatted pages, table layouts, embedded images, dark theme |
| **📊 Spreadsheet Viewer** | `com.peekit.sheet-viewer` | `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods` | Excel workbook grid, formula support, multi-sheet tabs, live cell searching & filtering |
| **📽️ Presentation Viewer** | `com.peekit.slides-viewer` | `.pptx`, `.ppt` | PowerPoint presentation viewer, keyboard slide navigation, interactive thumbnail sidebar |
| **🖌️ Adobe Illustrator Viewer** | `com.peekit.ai-viewer` | `.ai` | Vector artwork preview, artboard switching, smooth zoom & pan, transparency checkerboard |
| **🖼️ Adobe Photoshop Viewer** | `com.peekit.psd-viewer` | `.psd` | Photoshop PSD inspector: composite rendering, layer breakdown, dimensions & transparency |

---

## 📁 Структура репозитория / Repository Layout

```text
peekit-plugins/
├── .agents/                     # Конфигурация AI-агентов и навыков (Google Antigravity)
│   ├── agents/                  # Субагент peekit_plugin_creator
│   └── skills/                  # Навык peekit-plugin-creator
├── plugins/                     # Исходный код официальных плагинов
│   ├── peekit-plugin-3d/        # 3D модели (STL, OBJ, GLTF, PLY)
│   ├── peekit-plugin-ai/        # Adobe Illustrator (.ai)
│   ├── peekit-plugin-docx/      # Word документы (DOCX, DOC)
│   ├── peekit-plugin-font/      # Шрифты (TTF, OTF, WOFF, WOFF2)
│   ├── peekit-plugin-psd/       # Adobe Photoshop (.psd)
│   ├── peekit-plugin-sheet/     # Электронные таблицы (XLSX, XLS, CSV)
│   └── peekit-plugin-slides/    # Презентации (PPTX, PPT)
├── template/                    # Шаблон-заготовка для создания новых плагинов
├── pack_plugin.cjs              # Автоматический упаковщик плагинов в формат .pkit
├── plugin-schema.json           # JSON Schema для валидации манифестов
├── docs/                       # Центр расширенной документации и гайдов (Quickstart, RPC, I18N, Style, Testing, FAQ)
├── registry.json                # Центральный каталог плагинов (метаданные, версии)
├── website/                     # Промо-сайт и веб-маркетплейс плагинов (Flutter Web)
├── PLUGIN_DEVELOPMENT_GUIDE.md  # Полное руководство разработчика плагинов
└── README.md                    # Этот документ
```

---

## 🛠️ Сборка и разработка / Development

### 1. Формат плагинов `.pkit`

Файл с расширением **`.pkit`** — это защищённый ZIP-архив, содержащий `manifest.json`, точку входа `index.html` и все необходимые скрипты и стили без внешних сетевых зависимостей.

### 2. Упаковка плагинов через Node.js CLI

```bash
# Упаковать конкретный плагин
node pack_plugin.cjs plugins/peekit-plugin-3d

# Проверить и упаковать сразу ВСЕ плагины репозитория
node pack_plugin.cjs --all
```

Утилита автоматически валидирует `manifest.json`, упаковывает ассеты в `dist/`, вычисляет контрольные суммы **SHA-256** и обновляет `registry.json`.

### 3. Запуск веб-маркетплейса (Flutter Web)

```bash
cd website
flutter pub get
flutter run -d chrome
```

Подробная документация и руководства доступны в:  
👉 **[Центр документации (docs/)](docs/README.md)** • **[Быстрый старт за 10 минут](docs/QUICKSTART.md)** • **[PLUGIN_DEVELOPMENT_GUIDE.md](PLUGIN_DEVELOPMENT_GUIDE.md)**  
Вопросы безопасности песочницы описаны в **[SECURITY.md](SECURITY.md)**, а правила контрибьюции — в **[CONTRIBUTING.md](CONTRIBUTING.md)**.

---

## 🌐 Экосистема Kobalt Tools

| Проект | Описание | Стек | Ссылки |
| :--- | :--- | :--- | :--- |
| 📥 **StashIt** | Плавающий карман Drag-and-Drop (Dropover / Yoink для Windows) | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/StashIt) • [Web](https://kobaltgit.github.io/StashIt/) |
| 🗑️ **MiniBin** | Умная корзина в системном трее с Flyout-интерфейсом | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/minibin) • [Web](https://kobaltgit.github.io/minibin/) |
| ⏱️ **Undoit** | Локальная машина времени и версионирование файлов (Ctrl+Z) | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/undoit) • [Web](https://kobaltgit.github.io/Undoit/) |
| 🌐 **PolyShift** | HUD-помощник и контекстный перевод у курсора с Gemini AI | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/polyshift) • [Web](https://kobaltgit.github.io/polyshift/) |
| 👁️ **PeekIt** | Мгновенный предпросмотр файлов по клавише Space | Rust + Tauri v2 + Svelte 5 | [Repo](https://github.com/kobaltgit/peekit) • [Web](https://kobaltgit.github.io/PeekIt/) |
| 🧩 **PeekIt Plugins** | Официальный реестр и SDK веб-плагинов для PeekIt | TypeScript + Web SDK | [Repo](https://github.com/kobaltgit/peekit-plugins) • [Web](https://kobaltgit.github.io/peekit-plugins/) |
| 🎨 **kobalt_ui** | Общая библиотека UI компонентов (шапка, футер, релизы) | Flutter Web (Dart) | [Repo](https://github.com/kobaltgit/kobalt_ui) |

---

## 📄 Лицензия / License

Все плагины, SDK и шаблоны распространяются под открытой лицензией **[MIT](LICENSE)**.  
© 2026 Kobalt Tools / PeekIt.
