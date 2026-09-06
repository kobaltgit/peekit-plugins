function extractLayerSummary(layers) {
  if (!layers || !layers.length) return [];
  return layers.map(l => ({
    name: l.name || 'Слой',
    hidden: !!l.hidden,
    opacity: l.opacity !== undefined ? l.opacity : 1,
    blendMode: l.blendMode || 'normal',
    isText: !!l.text,
    children: l.children ? extractLayerSummary(l.children) : []
  }));
}

const fs = require('fs');
const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

agPsd.initializeCanvas((w, h) => ({
  width: w, height: h,
  getContext: () => ({ createImageData: (w, h) => ({ width: w, height: h, data: new Uint8Array(w * h * 4) }), putImageData: () => {} })
}));

const buf = fs.readFileSync('d:\\Users\\Kobalt\\Pictures\\t-shirt-mockup-01\\t-shirt-mockup-01.psd');
const p = agPsd.readPsd(buf.buffer, { skipLayerImageData: true, skipThumbnail: true, skipLinkedFilesData: true });

const meta = extractLayerSummary(p.children);
console.log('Layer count:', meta.length);
console.log('Sample layer:', meta[0]);
