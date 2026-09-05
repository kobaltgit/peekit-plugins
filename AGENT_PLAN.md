# 🤖 План реализации системы плагинов для ИИ-агента

Данный документ представляет собой пошаговый инженерный план для автономного ИИ-агента или разработчика. Каждая задача сопровождается точным списком файлов, контрактов и критериев приемки (DoD).

---

## 🎯 Цели и архитектурный контракт
1. Реализовать безопасный хостинг веб-плагинов в **PeekIt** (Tauri v2 + Svelte 5).
2. Обеспечить изолированное исполнение через `<iframe sandbox="allow-scripts">`.
3. Реализовать быстрый протокол отдачи ресурсов `plugin-asset://<plugin-id>/...`.
4. Реализовать передачу бинарных данных файла в плагин без дублирования памяти (`postMessage Transferable`).
5. Предоставить рабочий референсный плагин **`peekit-plugin-font`** для просмотра `.ttf`, `.otf`, `.woff`, `.woff2`.
6. Сформировать SDK и шаблон для сообщества.

---

## 📋 ЭТАП 1: Rust Backend в PeekIt (`src-tauri`)

### Задача 1.1: Модели и парсер манифеста
* **Файлы:**
  - `src-tauri/src/plugins/mod.rs`
  - `src-tauri/src/plugins/manifest.rs`
* **Требования:**
  - Структура `PluginManifest` (`id`, `name`, `version`, `author`, `description`, `extensions`, `entry`, `permissions`, `min_peekit_version`).
  - Структура `PluginInfo` (`manifest: PluginManifest`, `root_path: String`, `is_enabled: bool`).
  - Валидация полей (корректность расширений файла, проверка отсутствия выхода за пределы папки через `entry`).

### Задача 1.2: Сканер директории плагинов
* **Файл:** `src-tauri/src/plugins/scanner.rs`
* **Логика работы:**
  1. Определение пути к плагинам:
     - Портабельный режим: если рядом с исполняемым файлом есть `plugins/` или `portable.txt`.
     - Стандартный режим: `%APPDATA%\Peekit\plugins`.
  2. Автоматическое создание директории, если она отсутствует.
  3. Сканирование каждой подпапки на наличие `manifest.json`.
  4. Защита от сбоев: битый JSON или ошибки доступа в одной папке не должны прерывать сканирование остальных.

### Задача 1.3: Нативный протокол `plugin-asset://`
* **Файл:** `src-tauri/src/lib.rs` (или `src-tauri/src/plugins/protocol.rs`)
* **Реализация:**
  - Регистрация схемы в `tauri::Builder`:
    ```rust
    .register_uri_scheme_protocol("plugin-asset", |app, request| { ... })
    ```
  - Парсинг URI: `plugin-asset://<plugin-id>/<relative-path>`.
  - **Критически важно:** Строгая защита от Path Traversal (`std::path::Path::canonicalize` с проверкой `starts_with(plugin_dir)`).
  - Определение MIME-типа через `mime_guess` и возврат HTTP 200 с корректными заголовками (CORS `Access-Control-Allow-Origin: *`, `Content-Type`).

### Задача 1.4: IPC-команды для управления плагинами
* **Файл:** `src-tauri/src/commands/plugins.rs`
* **Команды:**
  - `#[tauri::command] fn get_installed_plugins() -> Result<Vec<PluginInfo>, String>`
  - `#[tauri::command] fn open_plugins_folder() -> Result<(), String>`
  - `#[tauri::command] fn read_binary_for_plugin(path: String) -> Result<Vec<u8>, String>`
  - Регистрация команд в `tauri::generate_handler![]` в `src-tauri/src/lib.rs`.

---

## 📋 ЭТАП 2: Frontend Host в PeekIt (`src/lib`)

### Задача 2.1: Протокол RPC Host ↔ Plugin
* **Файл:** `src/lib/plugins/protocol.ts`
* **Определение типов:**
  ```typescript
  export type HostToPluginMessage =
    | { type: 'PEEKIT_INIT'; payload: { filePath: string; fileName: string; fileSize: number; theme: 'dark' | 'light' } }
    | { type: 'PEEKIT_THEME_CHANGED'; payload: { theme: 'dark' | 'light' } }
    | { type: 'PEEKIT_DATA_RESPONSE'; payload: ArrayBuffer };

  export type PluginToHostMessage =
    | { type: 'PEEKIT_READY' }
    | { type: 'PEEKIT_REQUEST_DATA' }
    | { type: 'PEEKIT_RESIZE'; payload: { width: number; height: number } };
  ```

### Задача 2.2: Реестр плагинов (Svelte 5 Runes)
* **Файл:** `src/lib/stores/plugins.svelte.ts`
* **Функционал:**
  - Загрузка установленных плагинов при старте (`get_installed_plugins`).
  - Быстрая карта `extensionMap = new Map<string, PluginInfo>()` по расширениям.
  - Метод `findPluginForFile(extension: string): PluginInfo | undefined`.
  - Реактивное обновление по команде reload.

### Задача 2.3: Компонент контейнера `<PluginHost.svelte>`
* **Файл:** `src/lib/components/PluginHost.svelte`
* **Поведение:**
  1. Рендерит `<iframe sandbox="allow-scripts" src="plugin-asset://{plugin.manifest.id}/{plugin.manifest.entry}">`.
  2. Перехватывает `window.addEventListener('message', ...)`.
  3. При получении `PEEKIT_READY` посылает `PEEKIT_INIT`.
  4. При получении `PEEKIT_REQUEST_DATA` читает бинарный буфер через `read_binary_for_plugin` и отсылает `PEEKIT_DATA_RESPONSE` через `postMessage(data, '*', [data.buffer])`.
  5. Показывает плавный индикатор загрузки и аккуратную плашку ошибки, если iframe не ответил вовремя (таймаут).

### Задача 2.4: Интеграция в диспетчер просмотрщиков
* **Файл:** `src/routes/+page.svelte`
* **Логика:**
  - Если файл не поддерживается нативно, проверяем `pluginRegistry.findPluginForFile(currentFile.extension)`.
  - Если плагин найден — монтируем `<PluginHost plugin={plugin} file={currentFile} />`.
  - Если плагин не найден — рендерится стандартный `GenericPreview`.

---

## 📋 ЭТАП 3: Референсный плагин `peekit-plugin-font`

### Задача 3.1: Верстка и функционал просмотра шрифта
* **Файлы:**
  - `peekit-plugins/plugins/peekit-plugin-font/manifest.json`
  - `peekit-plugins/plugins/peekit-plugin-font/index.html`
* **Возможности:**
  1. Прием `ArrayBuffer` шрифта по протоколу PeekIt.
  2. Регистрация в браузере через `new FontFace('CustomFont', arrayBuffer)` и `document.fonts.add()`.
  3. UI:
     - Название и размер шрифта.
     - Интерактивный ввод произвольного текста.
     - Ползунок масштаба кегля (размера шрифта от 12px до 96px).
     - Предустановленные панграммы (русский, английский, цифры, знаки пунктуации).
     - Таблица глифов.
     - Полная адаптация под Fluent / Mica тему (темная / светлая).

---

## 📋 ЭТАП 4: UI управления плагинами в PeekIt

### Задача 4.1: Вкладка настроек «Плагины»
* **Файлы:**
  - `src/lib/components/settings/PluginsTab.svelte`
  - `src/lib/components/SettingsModal.svelte`
* **Элементы UI:**
  - Карточки установленных плагинов (Иконка, Имя, Версия, Автор, Поддерживаемые форматы).
  - Тумблер включения/отключения плагина.
  - Кнопка **«Открыть папку плагинов»** (вызов `open_plugins_folder`).
  - Кнопка **«Обновить список»**.

---

## 📋 ЭТАП 5: Экосистема и Starter Kit (`peekit-plugins`)

### Задача 5.1: Библиотека SDK
* **Файл:** `peekit-plugins/template/src/sdk.ts`
* **Методы:**
  - `peekit.onInit((info) => void)`
  - `peekit.onThemeChange((theme) => void)`
  - `peekit.requestData(): Promise<ArrayBuffer>`
  - `peekit.resize(width, height): void`

### Задача 5.2: CI/CD Валидатор Pull Request'ов
* **Файл:** `peekit-plugins/.github/workflows/validate.yml`
* **Автоматические проверки:**
  - Валидация всех `manifest.json` по `plugin-schema.json`.
  - Проверка отсутствия дубликатов `id`.
  - Проверка валидности версий SemVer.

---

## ✅ Критерии приемки (Definition of Done)
1. **Изоляция:** Падение или зависание плагина не закрывает и не замораживает окно PeekIt.
2. **Нулевой оверхед:** Для нативных типов (изображения, видео, текст) оверхед равен 0 мс (плагины не замедляют горячий путь).
3. **Безопасность:** Попытка загрузить `plugin-asset://com.peekit.font/../../Windows/notepad.exe` отклоняется со статусом 403/404.
4. **Готовый результат:** Копирование папки `peekit-plugin-font` в `%APPDATA%\Peekit\plugins` позволяет по нажатию Пробела на любом `.ttf` / `.otf` файле мгновенно открыть интерактивную панель просмотра шрифта.
