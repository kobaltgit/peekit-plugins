const agPsd = require('../node_modules/ag-psd/dist/bundle.js');

const psd = {
  width: 200,
  height: 100,
  children: [
    {
      name: 'Background',
      opacity: 1,
      blendMode: 'normal'
    },
    {
      name: 'Text Layer',
      opacity: 0.8,
      blendMode: 'screen'
    }
  ]
};

const buffer = agPsd.writePsdBuffer(psd);
console.log('Written buffer length:', buffer.length);

const readBack = agPsd.readPsd(buffer, { skipLayerImageData: true, skipCompositeImageData: true });
console.log('Read back:', {
  width: readBack.width,
  height: readBack.height,
  colorMode: readBack.colorMode,
  bitsPerChannel: readBack.bitsPerChannel,
  childrenCount: readBack.children ? readBack.children.length : 0,
  layerNames: readBack.children ? readBack.children.map(c => c.name) : []
});
