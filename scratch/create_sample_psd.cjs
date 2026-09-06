const fs = require('fs');
const path = require('path');
const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

const psd = {
  width: 400,
  height: 300,
  children: [
    {
      name: 'Background Fill',
      opacity: 1,
      blendMode: 'normal'
    },
    {
      name: 'Geometric Shape',
      opacity: 0.9,
      blendMode: 'multiply'
    },
    {
      name: 'Title Text',
      opacity: 1,
      blendMode: 'normal',
      text: {
        text: 'PeekIt Photoshop Viewer'
      }
    }
  ]
};

const buf = agPsd.writePsdBuffer(psd);
fs.writeFileSync(path.join(__dirname, 'sample.psd'), buf);
console.log('Sample PSD created:', path.join(__dirname, 'sample.psd'), 'size:', buf.length, 'bytes');
