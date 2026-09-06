const fs = require('fs');
const UTIF = require('utif');

function parseEpsHeader(buffer) {
  const bytes = new Uint8Array(buffer);
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);

  // Check for DOS EPS binary header: 0xC5D0D3C6 (or 0xC6D3D0C5 little-endian)
  const isDosEps = bytes[0] === 0xC5 && bytes[1] === 0xD0 && bytes[2] === 0xD3 && bytes[3] === 0xC6;

  let psOffset = 0;
  let psLength = bytes.length;
  let tiffOffset = 0;
  let tiffLength = 0;
  let wmfOffset = 0;
  let wmfLength = 0;

  if (isDosEps && bytes.length >= 30) {
    psOffset = view.getUint32(4, true);
    psLength = view.getUint32(8, true);
    wmfOffset = view.getUint32(12, true);
    wmfLength = view.getUint32(16, true);
    tiffOffset = view.getUint32(20, true);
    tiffLength = view.getUint32(24, true);
  } else {
    // ASCII EPS: search for %!PS
    for (let i = 0; i < Math.min(bytes.length - 1, 1024); i++) {
      if (bytes[i] === 0x25 && bytes[i + 1] === 0x21) { // '%!'
        psOffset = i;
        break;
      }
    }
  }

  // Read PostScript header text to extract metadata
  const maxHeaderRead = Math.min(psLength, 16384);
  const headerSlice = bytes.subarray(psOffset, psOffset + maxHeaderRead);
  let headerText = '';
  for (let i = 0; i < headerSlice.length; i++) {
    headerText += String.fromCharCode(headerSlice[i]);
  }

  const metadata = {
    isDosEps,
    hasTiff: tiffLength > 0,
    tiffOffset,
    tiffLength,
    hasWmf: wmfLength > 0,
    psOffset,
    psLength,
    creator: null,
    title: null,
    creationDate: null,
    bbox: null, // [x0, y0, x1, y1]
    width: null,
    height: null
  };

  const lines = headerText.split(/[\r\n]+/);
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith('%%Creator:')) {
      metadata.creator = trimmed.replace('%%Creator:', '').trim();
    } else if (trimmed.startsWith('%%Title:')) {
      metadata.title = trimmed.replace('%%Title:', '').trim();
    } else if (trimmed.startsWith('%%CreationDate:')) {
      metadata.creationDate = trimmed.replace('%%CreationDate:', '').trim();
    } else if (trimmed.startsWith('%%BoundingBox:') && !metadata.bbox) {
      const parts = trimmed.replace('%%BoundingBox:', '').trim().split(/\s+/).map(Number);
      if (parts.length === 4 && parts.every(n => !isNaN(n))) {
        metadata.bbox = parts;
        metadata.width = Math.abs(parts[2] - parts[0]);
        metadata.height = Math.abs(parts[3] - parts[1]);
      }
    } else if (trimmed.startsWith('%%HiResBoundingBox:') || trimmed.startsWith('%%CropBox:')) {
      const parts = trimmed.split(':')[1]?.trim().split(/\s+/).map(Number);
      if (parts && parts.length === 4 && parts.every(n => !isNaN(n))) {
        metadata.width = Math.round(Math.abs(parts[2] - parts[0]));
        metadata.height = Math.round(Math.abs(parts[3] - parts[1]));
      }
    }
  }

  return metadata;
}

console.log('parseEpsHeader function loaded successfully');

const asciiData = fs.readFileSync('scratch/sample_ascii.eps');
console.log('ASCII EPS meta:', parseEpsHeader(asciiData));

const dosData = fs.readFileSync('scratch/sample_dos_tiff.eps');
const dosMeta = parseEpsHeader(dosData);
console.log('DOS EPS meta:', dosMeta);

if (dosMeta.hasTiff) {
  const tiffSlice = dosData.subarray(dosMeta.tiffOffset, dosMeta.tiffOffset + dosMeta.tiffLength);
  const ifds = UTIF.decode(tiffSlice);
  UTIF.decodeImage(tiffSlice, ifds[0]);
  const rgba = UTIF.toRGBA8(ifds[0]);
  console.log('TIFF preview decoded successfully! Width:', ifds[0].width, 'Height:', ifds[0].height, 'RGBA length:', rgba.length);
}
