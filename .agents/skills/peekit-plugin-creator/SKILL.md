---
name: peekit-plugin-creator
description: Пошаговое руководство и правила для создания, упаковки в .pkit, тестирования и публикации плагинов в репозиторий peekit-plugins и маркетплейс PeekIt. Активируйте при создании нового плагина или обновлении существующего.
---

# PeekIt Plugin Creator Skill

Это руководство определяет стандарты разработки и публикации плагинов для приложения быстрого предпросмотра файлов **PeekIt**.

---

## 1. Главные правила разработки плагинов

1. **Self-Contained (Строгий Offline)**:
   - В плагине не должно быть внешних ссылок на CDN (`cdn.jsdelivr.net`, `unpkg.com`, `cdnjs.cloudflare.com` и т.д.).
   - Все зависимости (библиотеки JS, стили CSS, иконки SVG/Base64) должны находиться локально в архиве плагина.
   - **Рекомендация**: Однофайловая архитектура (`index.html`), где все скрипты объединены или инлайнены, работает наиболее надёжно в изолированном WebView2 (`asset.localhost`).

2. **IPC Соглашения (`window.postMessage`)**:
   - Плагин слушает событие `'message'` от окна приложения.
   - При получении `{ type: 'PEEKIT_INIT', filePath, fileType, settings, theme }`:
     - Считывает тему (`theme.isDark`, `theme.accentColor`).
     - Отправляет `{ type: 'PEEKIT_REQUEST_DATA', responseType: 'base64' | 'text' | 'binary' }`.
   - При получении `{ type: 'PEEKIT_DATA_RESPONSE', data, error }`:
     - Рендерит контент или показывает информативную ошибку.
     - Отправляет `{ type: 'PEEKIT_READY' }` родительскому окну.

3. **Схема манифеста (`manifest.json`)**:
   - `id`: обратная доменная нотация (`com.peekit.<slug>`).
   - `name`: понятное имя плагина.
   - `version`: semver (например, `1.0.0`).
   - `entry`: точка входа (`index.html`).
   - `supportedExtensions`: массив расширений в нижнем регистре с точкой, например `[".ai", ".eps"]`.
   - `category`: одна из: `Graphics`, `Office`, `Media`, `Code`, `Archive`, `Utilities`.

---

## 2. Порядок создания и упаковки

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

## 3. Интеграция в установленное приложение PeekIt (Windows)

Для тестирования «в бою»:
- Скопировать папку плагина в `D:\Peekit\plugins\<id>`
- Перезапустить `D:\Peekit\peekit.exe`
- Проверить лог `D:\Peekit\peekit.log` на наличие строки:
  `[PluginScanner] Loaded plugin '<Name>' v<Version> ([...]) enabled=true from ...`
