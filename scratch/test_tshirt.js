const fs = require('fs');
const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

const filePath = 'd:\\Users\\Kobalt\\Pictures\\t-shirt-mockup-01\\t-shirt-mockup-01.psd';
console.log('Loading file:', filePath);
const buffer = fs.readFileSync(filePath);
console.log('File size:', (buffer.length / 1024 / 1024).toFixed(2), 'MB');

// Mock canvas
let canvasCreated = [];
agPsd.initializeCanvas(
  (width, height) => {
    const c = {
      width,
      height,
      getContext: () => ({
        createImageData: (w, h) => ({ width: w, height: h, data: new Uint8Array(w * h * 4) }),
        putImageData: (imgData, x, y) => {
          c.hasData = true;
          // check if data is not all zeroes
          let nonZero = 0;
          for (let i = 0; i < Math.min(imgData.data.length, 10000); i++) {
            if (imgData.data[i] !== 0) nonZero++;
          }
          c.nonZeroSample = nonZero;
        },
        drawImage: () => {}
      })
    };
    canvasCreated.push(c);
    return c;
  }
);

console.time('readPsd');
const psd = agPsd.readPsd(buffer.buffer, { skipLayerImageData: true, skipThumbnail: true });
console.timeEnd('readPsd');

console.log('Result:', {
  width: psd.width,
  height: psd.height,
  colorMode: psd.colorMode,
  hasCanvas: !!psd.canvas,
  canvasWidth: psd.canvas ? psd.canvas.width : 0,
  canvasHeight: psd.canvas ? psd.canvas.height : 0,
  canvasHasData: psd.canvas ? psd.canvas.hasData : false,
  canvasNonZeroSample: psd.canvas ? psd.canvas.nonZeroSample : 0,
  canvasesCreated: canvasCreated.length
});

if (psd.canvas) {
  console.log('Composite canvas details:', {
    hasData: psd.canvas.hasData,
    nonZeroSample: psd.canvas.nonZeroSample
  });
}
