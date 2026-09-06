const fs = require('fs');

// Load UDOC, FromPS, ToContext2D
const udocCode = fs.readFileSync('scratch/lib_eps/UDOC.js', 'utf8');
const fromPsCode = fs.readFileSync('scratch/lib_eps/FromPS.js', 'utf8');
const toContext2dCode = fs.readFileSync('scratch/lib_eps/ToContext2D.js', 'utf8');

// Create a sandbox execution
const vm = require('vm');
const canvasCalls = [];

const mockCtx = {
  translate: (x, y) => canvasCalls.push(['translate', x, y]),
  scale: (x, y) => canvasCalls.push(['scale', x, y]),
  beginPath: () => canvasCalls.push(['beginPath']),
  moveTo: (x, y) => canvasCalls.push(['moveTo', x, y]),
  lineTo: (x, y) => canvasCalls.push(['lineTo', x, y]),
  bezierCurveTo: (...args) => canvasCalls.push(['bezierCurveTo', ...args]),
  quadraticCurveTo: (...args) => canvasCalls.push(['quadraticCurveTo', ...args]),
  closePath: () => canvasCalls.push(['closePath']),
  fill: () => canvasCalls.push(['fill']),
  stroke: () => canvasCalls.push(['stroke']),
  save: () => canvasCalls.push(['save']),
  restore: () => canvasCalls.push(['restore']),
  transform: (...args) => canvasCalls.push(['transform', ...args]),
  fillText: (...args) => canvasCalls.push(['fillText', ...args]),
  setLineDash: (...args) => canvasCalls.push(['setLineDash', ...args]),
  createLinearGradient: () => ({ addColorStop: () => {} }),
  createRadialGradient: () => ({ addColorStop: () => {} }),
  createImageData: (w, h) => ({ data: new Uint8ClampedArray(w * h * 4) }),
  putImageData: () => {},
  drawImage: () => canvasCalls.push(['drawImage'])
};

const mockCanvas = {
  width: 0,
  height: 0,
  getContext: () => mockCtx,
  setAttribute: () => {}
};

const sandbox = {
  console,
  Date,
  Math,
  Uint8Array,
  Uint8ClampedArray,
  Int16Array,
  Uint16Array,
  Uint32Array,
  ArrayBuffer,
  DataView,
  parseFloat,
  parseInt,
  isNaN,
  window: {
    devicePixelRatio: 1
  },
  document: {
    createElement: (tag) => {
      if (tag === 'canvas') return Object.assign({}, mockCanvas);
      return {};
    }
  }
};

vm.createContext(sandbox);
vm.runInContext(udocCode, sandbox);
vm.runInContext(fromPsCode, sandbox);
vm.runInContext(toContext2dCode, sandbox);

console.log('UDOC loaded:', typeof sandbox.UDOC);
console.log('FromPS loaded:', typeof sandbox.FromPS);
console.log('ToContext2D loaded:', typeof sandbox.ToContext2D);

const asciiBuffer = fs.readFileSync('scratch/sample_ascii.eps');
const wrt = new sandbox.ToContext2D(0, 1);
sandbox.FromPS.Parse(asciiBuffer, wrt);

console.log('BoundingBox:', wrt.bb);
console.log('Canvas dimension:', wrt.canvas.width, 'x', wrt.canvas.height);
console.log('Canvas operations count:', canvasCalls.length);
console.log('First 10 canvas calls:', canvasCalls.slice(0, 10));
