const fs = require('fs');
const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

agPsd.initializeCanvas(
  (width, height) => {
    return {
      width,
      height,
      getContext: () => ({
        createImageData: (w, h) => ({ width: w, height: h, data: new Uint8Array(w * h * 4) }),
        putImageData: () => {},
        drawImage: () => {}
      })
    };
  }
);

const filePath = 'd:\\Users\\Kobalt\\Pictures\\t-shirt-mockup-01\\t-shirt-mockup-01.psd';
const buffer = fs.readFileSync(filePath);

function printMem(tag) {
  const m = process.memoryUsage();
  console.log(tag, {
    rss: Math.round(m.rss / 1024 / 1024) + ' MB',
    heapTotal: Math.round(m.heapTotal / 1024 / 1024) + ' MB',
    heapUsed: Math.round(m.heapUsed / 1024 / 1024) + ' MB'
  });
}

printMem('Before readPsd');
const psd = agPsd.readPsd(buffer.buffer, { skipLayerImageData: true, skipThumbnail: true });
printMem('After readPsd (skipLayerImageData: true)');

console.log('psd children count:', psd.children?.length);
console.log('psd imageResources:', Object.keys(psd.imageResources || {}));
console.log('psd linkedFiles:', psd.linkedFiles?.length);
