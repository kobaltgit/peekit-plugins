const fs = require('fs');
const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

const filePath = 'd:\\Users\\Kobalt\\Pictures\\t-shirt-mockup-01\\Displacement.psd';
console.log('Loading file:', filePath);
const buffer = fs.readFileSync(filePath);
console.log('File size:', (buffer.length / 1024 / 1024).toFixed(2), 'MB');

console.time('readPsd');
try {
  const psd = agPsd.readPsd(buffer, { skipLayerImageData: true, skipThumbnail: true });
  console.timeEnd('readPsd');
  console.log('PSD Metadata:', {
    width: psd.width,
    height: psd.height,
    colorMode: psd.colorMode,
    bitsPerChannel: psd.bitsPerChannel,
    children: psd.children ? psd.children.length : 0,
    hasCanvas: !!psd.canvas
  });
} catch (err) {
  console.timeEnd('readPsd');
  console.error('Error in readPsd:', err);
}
