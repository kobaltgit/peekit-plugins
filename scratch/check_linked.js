const fs = require('fs');
const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

agPsd.initializeCanvas((w, h) => ({
  width: w, height: h,
  getContext: () => ({
    createImageData: (w, h) => ({ width: w, height: h, data: new Uint8Array(w * h * 4) }),
    putImageData: () => {}, drawImage: () => {}
  })
}));

const filePath = 'd:\\Users\\Kobalt\\Pictures\\t-shirt-mockup-01\\t-shirt-mockup-01.psd';
const buffer = fs.readFileSync(filePath);

const p1 = agPsd.readPsd(buffer.buffer, { skipLayerImageData: true, skipThumbnail: true });
console.log('Without skipLinkedFilesData:', {
  linkedFiles: p1.linkedFiles?.length,
  linkedSizes: p1.linkedFiles?.map(f => (f.data ? (f.data.length / 1024 / 1024).toFixed(2) + ' MB' : 'no data'))
});

const p2 = agPsd.readPsd(buffer.buffer, { skipLayerImageData: true, skipThumbnail: true, skipLinkedFilesData: true });
console.log('With skipLinkedFilesData: true:', {
  linkedFiles: p2.linkedFiles?.length
});
