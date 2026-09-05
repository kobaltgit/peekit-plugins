# 🧩 PeekIt Plugins Ecosystem

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D4?logo=windows&logoColor=white)](https://github.com/kobaltgit/peekit)
[![Website](https://img.shields.io/badge/Website-Marketplace-success?logo=flutter)](https://kobaltgit.github.io/peekit-plugins/)
[![Ecosystem](https://img.shields.io/badge/Ecosystem-Kobalt%20Tools-blueviolet)](https://github.com/kobaltgit)
[![Host App](https://img.shields.io/badge/PeekIt-Quick%20Preview-blue)](https://github.com/kobaltgit/peekit)
[![Format](https://img.shields.io/badge/Format-.pkit-brightgreen)](PLUGIN_DEVELOPMENT_GUIDE.md)
[![Sandbox](https://img.shields.io/badge/Sandbox-WebView2%20IFrame-orange)](SECURITY.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Официальный репозиторий экосистемы плагинов для **[PeekIt](https://github.com/kobaltgit/peekit)** — ультрабыстрого инструмента предварительного просмотра файлов по клавише **Space (Пробел)** в Windows 10 & 11.

---

## ⚡ О системе плагинов

Плагины PeekIt представляют собой легковесные автономные веб-приложения (HTML5, JS, CSS, WebGL, WASM), исполняемые внутри изолированных контейнеров:

1. **Безопасная изоляция:** Плагины работают внутри `<iframe sandbox="allow-scripts">` без прямого доступа к файловой системе хоста.
2. **Нулевой оверхед:** Плагин активируется только в момент нажатия Пробела на поддерживаемом файле и мгновенно освобождает память при закрытии.
3. **Нативный RPC-протокол:** Быстрый двусторонний обмен данными через `window.postMessage` с передачей бинарных буферов (`ArrayBuffer`) без дублирования памяти.
4. **100% Автономность:** Все плагины работают без подключения к интернету.

---

## 📦 Каталог официальных плагинов

| Плагин | Идентификатор | Форматы | Описание |
| :--- | :--- | :--- | :--- |
| **🎨 Font Viewer** | `com.peekit.font-viewer` | `.ttf`, `.otf`, `.woff`, `.woff2` | Предпросмотр шрифтов, панграммы, таблица глифов Unicode, санитайзер OpenType |
| **🧊 3D Model Viewer** | `com.peekit.3d-viewer` | `.stl`, `.obj`, `.gltf`, `.glb`, `.ply` | Аппаратный 3D-вьюпорт (Three.js), вертушка 360°, сетка, материалы, полигоны |
| **📄 Word Document Viewer** | `com.peekit.docx-viewer` | `.docx`, `.doc` | Просмотр Word-документов: печатный лист A4, таблицы, изображения, ночной режим |
| **📊 Spreadsheet Viewer** | `com.peekit.sheet-viewer` | `.xlsx`, `.xls`, `.csv`, `.tsv`, `.ods` | Сетка Excel с формулами, вкладки листов, живой поиск и фильтрация ячеек |
| **📽️ Presentation Viewer** | `com.peekit.slides-viewer` | `.pptx`, `.ppt` | Слайд-шоу PowerPoint, навигация стрелками клавиатуры, боковая лента миниатюр |

---

## 📁 Структура репозитория

```text
peekit-plugins/
├── plugins/                     # Исходный код официальных плагинов
│   ├── peekit-plugin-3d/        # 3D модели (STL, OBJ, GLTF, PLY)
│   ├── peekit-plugin-docx/      # Word документы (DOCX, DOC)
│   ├── peekit-plugin-font/      # Шрифты (TTF, OTF, WOFF, WOFF2)
│   ├── peekit-plugin-sheet/     # Электронные таблицы (XLSX, XLS, CSV)
│   └── peekit-plugin-slides/    # Презентации (PPTX, PPT)
├── template/                    # Шаблон-заготовка для создания новых плагинов
├── pack_plugin.cjs              # Автоматический упаковщик плагинов в формат .pkit
├── plugin-schema.json           # JSON Schema для валидации манифестов
├── registry.json                # Центральный каталог плагинов (метаданные, версии)
├── PLUGIN_DEVELOPMENT_GUIDE.md  # Полное руководство разработчика плагинов
└── README.md                    # Этот документ
```

---

## 🛠️ Разработка и упаковка плагинов

### 1. Формат .pkit

**.pkit** — официальный формат дистрибуции плагинов PeekIt. Представляет собой ZIP-архив с манифестом `manifest.json`, точкой входа `index.html` и ассетами.

### 2. Сборка плагинов одной командой

Для сборки плагинов используется встроенная утилита:

```bash
# Упаковать конкретный плагин
node pack_plugin.cjs plugins/peekit-plugin-3d

# Упаковать сразу ВСЕ плагины репозитория
node pack_plugin.cjs --all
```

Скрипт автоматически проверит манифест, сожмет файлы, создаст архив `.pkit` в папке `dist/` и вычислит контрольную сумму **SHA-256**.

### 3. Руководство разработчика

Подробные инструкции по созданию нового плагина с нуля, спецификация протокола сообщений и требования к оформлению описаны в:
👉 **[PLUGIN_DEVELOPMENT_GUIDE.md](PLUGIN_DEVELOPMENT_GUIDE.md)**

---

## 🤝 Участие в разработке

Инструкции по добавлению новых плагинов, созданию Pull Request и стандартам кода описаны в **[CONTRIBUTING.md](CONTRIBUTING.md)**.  
Вопросы безопасности и изолированной среды описаны в **[SECURITY.md](SECURITY.md)**.

---

## 📄 Лицензия

Все официальные плагины и шаблоны распространяются под свободной лицензией **[MIT](LICENSE)**. © 2026 Kobalt Tools / PeekIt.
