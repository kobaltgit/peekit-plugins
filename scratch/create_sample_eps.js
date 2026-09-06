const fs = require('fs');
const UTIF = require('utif');

// 1. Create a clean ASCII EPS with vector graphics
const asciiEps = `%!PS-Adobe-3.0 EPSF-3.0
%%Creator: PeekIt Test Generator
%%Title: Sample Vector EPS
%%CreationDate: 2026-09-06
%%BoundingBox: 0 0 400 300
%%HiResBoundingBox: 0.000 0.000 400.000 300.000
%%Pages: 1
%%EndComments

%%Page: 1 1
gsave
% Draw background rectangle
0.95 0.95 0.98 setrgbcolor
0 0 moveto 400 0 lineto 400 300 lineto 0 300 lineto closepath fill

% Draw a stylish circle
1.0 0.3 0.2 setrgbcolor
200 150 70 0 360 arc
fill

% Draw blue rectangle
0.2 0.5 1.0 setrgbcolor
50 50 moveto 150 50 lineto 150 130 lineto 50 130 lineto closepath fill

% Draw a line
0.1 0.1 0.1 setrgbcolor
3 setlinewidth
50 220 moveto
350 220 lineto
stroke

grestore
showpage
%%EOF
`;

fs.writeFileSync('scratch/sample_ascii.eps', asciiEps, 'utf8');
console.log('Saved scratch/sample_ascii.eps');

// 2. Create a DOS EPS with an embedded TIFF preview
// Let's create a small 64x64 RGBA image as TIFF
const tiffW = 64;
const tiffH = 64;
const rgba = new Uint8Array(tiffW * tiffH * 4);
for (let y = 0; y < tiffH; y++) {
  for (let x = 0; x < tiffW; x++) {
    const idx = (y * tiffW + x) * 4;
    rgba[idx] = Math.round((x / tiffW) * 255);       // R
    rgba[idx + 1] = Math.round((y / tiffH) * 255);   // G
    rgba[idx + 2] = 220;                             // B
    rgba[idx + 3] = 255;                             // A
  }
}

const tiffBytes = new Uint8Array(UTIF.encodeImage(rgba, tiffW, tiffH));
const psBytes = Buffer.from(asciiEps, 'utf8');

// Build 30-byte DOS EPS header:
// 0..3: 0xC5, 0xD0, 0xD3, 0xC6
// 4..7: PS offset
// 8..11: PS length
// 12..15: WMF offset (0)
// 16..19: WMF length (0)
// 20..23: TIFF offset
// 24..27: TIFF length
// 28..29: Checksum (0xFFFF)
const header = Buffer.alloc(30);
header[0] = 0xC5;
header[1] = 0xD0;
header[2] = 0xD3;
header[3] = 0xC6;

const psOffset = 30;
const psLength = psBytes.length;
const tiffOffset = psOffset + psLength;
const tiffLength = tiffBytes.length;

header.writeUInt32LE(psOffset, 4);
header.writeUInt32LE(psLength, 8);
header.writeUInt32LE(0, 12);
header.writeUInt32LE(0, 16);
header.writeUInt32LE(tiffOffset, 20);
header.writeUInt32LE(tiffLength, 24);
header.writeUInt16LE(0xFFFF, 28);

const dosEpsBuffer = Buffer.concat([header, psBytes, Buffer.from(tiffBytes)]);
fs.writeFileSync('scratch/sample_dos_tiff.eps', dosEpsBuffer);
console.log('Saved scratch/sample_dos_tiff.eps (total size: ' + dosEpsBuffer.length + ' bytes)');
