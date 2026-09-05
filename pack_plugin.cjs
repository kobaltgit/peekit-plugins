const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const vm = require('vm');

// Find JSZip
const candidatePaths = [
  path.join(__dirname, 'plugins', 'peekit-plugin-docx', 'jszip.min.js'),
  path.join(__dirname, '..', 'plugins', 'peekit-plugin-docx', 'jszip.min.js'),
  path.join(__dirname, '..', 'PeekIt', 'plugins', 'peekit-plugin-docx', 'jszip.min.js')
];

let JSZip;
let jszipFoundPath = candidatePaths.find(p => fs.existsSync(p));

if (jszipFoundPath) {
  const jszipCode = fs.readFileSync(jszipFoundPath, 'utf8');
  const jszipCtx = { window: {}, Buffer, Uint8Array, setTimeout, clearTimeout, setImmediate, clearImmediate };
  jszipCtx.window = jszipCtx;
  vm.createContext(jszipCtx);
  vm.runInContext(jszipCode, jszipCtx);
  JSZip = jszipCtx.JSZip;
} else {
  try {
    JSZip = require('jszip');
  } catch (e) {
    console.error('JSZip not found in candidate paths nor npm require');
    process.exit(1);
  }
}

const args = process.argv.slice(2);
const outputDir = path.join(__dirname, 'dist');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

async function packSinglePlugin(pluginDirPath) {
  const manifestPath = path.join(pluginDirPath, 'manifest.json');
  const indexPath = path.join(pluginDirPath, 'index.html');

  if (!fs.existsSync(manifestPath)) {
    throw new Error(`Manifest not found in ${pluginDirPath}`);
  }
  if (!fs.existsSync(indexPath)) {
    throw new Error(`index.html not found in ${pluginDirPath}`);
  }

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

  if (!manifest.id || !manifest.version || !manifest.name || !manifest.extensions) {
    throw new Error(`Manifest is missing required fields (id, version, name, extensions) in ${pluginDirPath}`);
  }

  const zip = new JSZip();

  // Add all files from plugin dir into zip root
  const files = fs.readdirSync(pluginDirPath);
  for (const f of files) {
    const fullPath = path.join(pluginDirPath, f);
    const stat = fs.statSync(fullPath);
    if (stat.isFile()) {
      zip.file(f, fs.readFileSync(fullPath));
    }
  }

  const u8 = await zip.generateAsync({
    type: 'uint8array',
    compression: 'DEFLATE',
    compressionOptions: { level: 9 }
  });

  const buffer = Buffer.from(u8);
  const outFileName = `${manifest.id}-${manifest.version}.pkit`;
  const outPath = path.join(outputDir, outFileName);

  fs.writeFileSync(outPath, buffer);

  const sha256 = crypto.createHash('sha256').update(buffer).digest('hex');
  const sizeKb = (buffer.length / 1024).toFixed(1);

  return {
    id: manifest.id,
    name: manifest.name,
    version: manifest.version,
    file: outFileName,
    path: outPath,
    sizeKb,
    sha256
  };
}

async function main() {
  console.log('=== PeekIt Plugin Packager (.pkit) ===\n');

  let targetDirs = [];

  if (args.includes('--all') || args.length === 0) {
    const pluginsDir = path.join(__dirname, 'plugins');
    if (fs.existsSync(pluginsDir)) {
      targetDirs = fs.readdirSync(pluginsDir)
        .map(d => path.join(pluginsDir, d))
        .filter(d => fs.statSync(d).isDirectory() && fs.existsSync(path.join(d, 'manifest.json')));
    }
  } else {
    targetDirs = args.map(a => path.resolve(a));
  }

  if (targetDirs.length === 0) {
    console.log('No plugins found to pack.');
    process.exit(1);
  }

  const results = [];

  for (const dir of targetDirs) {
    try {
      const res = await packSinglePlugin(dir);
      results.push(res);
      console.log(`вњ“ Packed: ${res.name} (${res.id}) -> ${res.file} [${res.sizeKb} KB]`);
    } catch (err) {
      console.error(`вњ— Error packing ${dir}:`, err.message);
    }
  }

  console.log('\n=== Summary of Packages ===');
  console.table(results.map(r => ({
    Plugin: r.name,
    File: r.file,
    'Size (KB)': r.sizeKb,
    SHA256: r.sha256.slice(0, 16) + '...'
  })));

  console.log(`\nPackages saved in: ${outputDir}`);
}

main().catch(console.error);