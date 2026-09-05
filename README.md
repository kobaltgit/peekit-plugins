# 🧩 PeekIt Plugins Ecosystem

Официальный репозиторий, реестр плагинов и набор для разработчиков (SDK / Starter Kit) для [PeekIt](https://github.com/kobaltgit/PeekIt) — сверхбыстрого инструмента предварительного просмотра файлов в Windows по нажатию Пробела.

---

## 📌 Оглавление
- [Архитектура плагинов](#архитектура-плагинов)
- [Структура репозитория](#структура-репозитория)
- [Спецификация манифеста (`manifest.json`)](#спецификация-манифеста-manifestjson)
- [Протокол взаимодействия (Host ↔ Plugin)](#протокол-взаимодействия-host--plugin)
- [Быстрый старт: Создание нового плагина](#быстрый-старт-создание-нового-плагина)
- [Центральный реестр (`registry.json`)](#центральный-реестр-registryjson)
- [План реализации для автономного агента](#план-реализации-для-автономного-агента)

---

## 🏗 Архитектура плагинов

Плагины PeekIt представляют собой веб-бандлы (HTML, JS, CSS, WASM), выполняющиеся внутри изолированного контейнера:
1. **Изоляция:** Плагины работают внутри `<iframe sandbox="allow-scripts">` без доступа к системным ресурсам и внутренней памяти хоста.
2. **Кастомный протокол:** Ресурсы плагина раздаются через быстрый и защищенный нативный протокол Tauri v2 `plugin-asset://<plugin-id>/...`.
3. **Обмен данными:** Все взаимодействие с хост-приложением (получение бинарных данных файла, метаданных, сведений о теме оформления) происходит через контролируемый `window.postMessage` с передачей владения буфером (`ArrayBuffer transferable`).

---

## 📂 Структура репозитория

```text
peekit-plugins/
├── .github/workflows/          # CI/CD автоматизация (валидация манифестов, сборка каталога)
├── plugins/                    # Исходный код проверенных плагинов сообщества
│   └── peekit-plugin-font/     # Референсный плагин: предпросмотр шрифтов (.ttf, .otf, .woff2)
├── template/                   # Шаблон (Starter Kit) для разработчиков плагинов
│   ├── manifest.json
│   ├── package.json
│   ├── index.html
│   └── src/
│       ├── sdk.ts             # Типизированный клиент связи с PeekIt
│       └── main.ts
├── plugin-schema.json          # Строгая JSON Schema для валидации manifest.json
├── registry.json               # Центральный реестр всех доступных плагинов
├── AGENT_PLAN.md               # Детальный пошаговый план реализации для ИИ-агента
└── README.md                   # Документация экосистемы
```

---

## 📄 Спецификация манифеста (`manifest.json`)

Каждый плагин должен содержать в корне `manifest.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/kobaltgit/peekit-plugins/main/plugin-schema.json",
  "id": "com.peekit.font-viewer",
  "name": "Font Viewer",
  "version": "1.0.0",
  "author": "Kobalt",
  "description": "Интерактивный просмотр шрифтов TTF, OTF, WOFF, WOFF2",
  "extensions": [".ttf", ".otf", ".woff", ".woff2"],
  "entry": "index.html",
  "min_peekit_version": "1.0.0",
  "permissions": ["read_file"],
  "icon": "icon.svg"
}
```

---

## 🔌 Протокол взаимодействия (Host ↔ Plugin)

| Направление | Сообщение / Событие | Полезная нагрузка (Payload) | Описание |
|---|---|---|---|
| **Plugin ➔ Host** | `PEEKIT_READY` | `{}` | Плагин готов принимать данные |
| **Host ➔ Plugin** | `PEEKIT_INIT` | `{ filePath, fileName, fileSize, theme }` | Начальные метаданные файла и темы |
| **Plugin ➔ Host** | `PEEKIT_REQUEST_DATA` | `{}` | Запрос бинарных данных файла |
| **Host ➔ Plugin** | `PEEKIT_DATA_RESPONSE` | `ArrayBuffer` | Бинарное содержимое файла (Zero-Copy) |
| **Plugin ➔ Host** | `PEEKIT_RESIZE` | `{ width, height }` | Запрос адаптации размеров окна предпросмотра |
| **Host ➔ Plugin** | `PEEKIT_THEME_CHANGED` | `{ theme: 'dark' | 'light' }` | Реакция на переключение темы в Windows/PeekIt |

---

## 🚀 Быстрый старт: Создание нового плагина

1. Скопируйте папку `template/` в новую директорию.
2. Обновите `manifest.json`, указав уникальный `id` и поддерживаемые расширения (`extensions`).
3. Запустите локальную разработку через `npm install` и `npm run dev`. В шаблоне предусмотрена заглушка (Mock Host), позволяющая тестировать плагин прямо в обычном браузере.
4. Соберите плагин командой `npm run build` и скопируйте артефакты в `%APPDATA%\Peekit\plugins\<id>\`.
5. Нажмите Пробел на файле соответствующего типа в Windows Explorer!
