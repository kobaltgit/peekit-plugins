import { peekit, type FileMetadata } from './sdk';

const loaderEl = document.getElementById('loader')!;
const contentEl = document.getElementById('content')!;
const fileTitleEl = document.getElementById('file-title')!;
const fileMetaEl = document.getElementById('file-meta')!;
const viewerEl = document.getElementById('viewer')!;

peekit.onInit(async (meta: FileMetadata) => {
  fileTitleEl.textContent = meta.fileName;
  fileMetaEl.textContent = `${(meta.fileSize / 1024).toFixed(1)} KB`;

  // Запрашиваем бинарные данные файла
  try {
    const buffer = await peekit.requestData();
    loaderEl.classList.add('hidden');
    contentEl.classList.remove('hidden');

    viewerEl.innerHTML = `
      <p style="margin-bottom: 12px; color: var(--accent);">
        Успешно получено ${buffer.byteLength} байт данных!
      </p>
      <pre style="background: var(--bg-primary); padding: 12px; border-radius: 8px; font-size: 12px; overflow: auto;">
Путь к файлу: ${meta.filePath}
Размер: ${meta.fileSize} байт
Тема оформления: ${meta.theme}
      </pre>
    `;
  } catch (err) {
    loaderEl.innerHTML = `<p style="color: #ef4444;">Ошибка загрузки файла: ${err}</p>`;
  }
});

// Сообщаем хосту о готовности
peekit.ready();
