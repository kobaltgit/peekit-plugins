const fs = require('fs');
const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

// Mock canvas for node
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

const filePath = 'd:\\Users\\Kobalt\\Pictures\\t-shirt-mockup-01\\Displacement.psd';
const buffer = fs.readFileSync(filePath);
console.log('Testing Displacement.psd, size:', (buffer.length / 1024 / 1024).toFixed(2), 'MB');

console.time('readPsd');
const psd = agPsd.readPsd(buffer.buffer, { skipLayerImageData: true, skipThumbnail: true });
console.timeEnd('readPsd');

console.log('Success! Result:', {
  width: psd.width,
  height: psd.height,
  colorMode: psd.colorMode,
  bitsPerChannel: psd.bitsPerChannel,
  childrenCount: psd.children ? psd.children.length : 0,
  hasCanvas: !!psd.canvas
});
