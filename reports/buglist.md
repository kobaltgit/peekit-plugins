# Баги, обнаруженные в процессе разработки

--

1. ~~_D:\Projects\active\peekit-plugins\plugins\peekit-plugin-docx_ не отображает файлы с расширением \***.doc**~~ — **Исправлено (v1.0.1)**:
   - Формат `.doc` (Word 97-2003) исключен из списка поддерживаемых расширений (`extensions: [".docx"]`).
   - В [index.html](file:///d:/Projects/active/peekit-plugins/plugins/peekit-plugin-docx/index.html) добавлена проверка magic-байтов OLE2/CFBF с информативным сообщением пользователю о необходимости пересохранения в современный `.docx`.
   - Пакет `com.peekit.docx-viewer-1.0.1.pkit` пересобран, реестры `registry.json` и файлы маркетплейса синхронизированы.
