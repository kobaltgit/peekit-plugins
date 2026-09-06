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

function auditPluginSecurity(pluginDirPath) {
  const violations = [];
  const files = fs.readdirSync(pluginDirPath);

  const forbiddenPatterns = [
    { pattern: /<script\s+[^>]*src=["']https?:\/\//i, desc: 'External script CDN loading detected' },
    { pattern: /<link\s+[^>]*href=["']https?:\/\//i, desc: 'External stylesheet/font CDN loading detected' },
    { pattern: /<iframe\s+[^>]*src=["']https?:\/\//i, desc: 'External iframe loading detected' },
    { pattern: /fetch\s*\(\s*["'`]https?:\/\//i, desc: 'Remote HTTP fetch call detected' },
    { pattern: /\.open\s*\(\s*["'`][A-Z]+["'`]\s*,\s*["'`]https?:\/\//i, desc: 'Remote XMLHttpRequest call detected' },
    { pattern: /new\s+WebSocket\s*\(\s*["'`]wss?:\/\//i, desc: 'Remote WebSocket connection detected' }
  ];

  for (const f of files) {
    if (f === 'manifest.json' || f.endsWith('.png') || f.endsWith('.jpg') || f.endsWith('.ico') || f.endsWith('.svg') || f.endsWith('.ttf') || f.endsWith('.woff') || f.endsWith('.woff2')) {
      continue;
    }
    const fullPath = path.join(pluginDirPath, f);
    if (!fs.statSync(fullPath).isFile()) continue;

    const content = fs.readFileSync(fullPath, 'utf8');
    for (const rule of forbiddenPatterns) {
      if (rule.pattern.test(content)) {
        violations.push(`${f}: ${rule.desc}`);
      }
    }
  }

  return violations;
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

  // Security audit
  const securityIssues = auditPluginSecurity(pluginDirPath);
  if (securityIssues.length > 0) {
    throw new Error(`Security audit failed:\n  ${securityIssues.join('\n  ')}`);
  }

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

  if (!manifest.id || !manifest.version || !manifest.name || !manifest.extensions) {
    throw new Error(`Manifest is missing required fields (id, version, name, extensions) in ${pluginDirPath}`);
  }

  const zip = new JSZip();

  // Add all files from plugin dir into zip root
  const files = fs.readdirSync(pluginDirPath).sort();
  for (const f of files) {
    const fullPath = path.join(pluginDirPath, f);
    const stat = fs.statSync(fullPath);
    if (stat.isFile()) {
      let data = fs.readFileSync(fullPath);
      if (/\.(json|html|js|css|md|txt|svg)$/i.test(f)) {
        data = Buffer.from(data.toString("utf8").replace(/\r\n/g, "\n"), "utf8");
      }
      zip.file(f, data, { date: new Date("2026-01-01T00:00:00Z"), createFolders: false });
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
    author: manifest.author || 'Community',
    description: manifest.description || '',
    extensions: manifest.extensions,
    entry: manifest.entry || 'index.html',
    icon: manifest.icon || 'file',
    homepage: manifest.homepage || 'https://github.com/kobaltgit/peekit-plugins',
    file: outFileName,
    path: outPath,
    sizeKb,
    sha256
  };
}

function updateRegistryFile(results) {
  const registryPath = path.join(__dirname, 'registry.json');
  let registry = {
    $schema: './plugin-schema.json',
    version: 1,
    updated_at: new Date().toISOString(),
    plugins: []
  };

  if (fs.existsSync(registryPath)) {
    try {
      registry = JSON.parse(fs.readFileSync(registryPath, 'utf8'));
      registry.updated_at = new Date().toISOString();
    } catch (e) {
      console.warn('Could not parse existing registry.json, creating fresh');
    }
  }

  for (const res of results) {
    const downloadUrl = `https://kobaltgit.github.io/peekit-plugins/plugins/${res.file}`;
    const releaseUrl = `https://github.com/kobaltgit/peekit-plugins/releases/download/v${res.version}/${res.file}`;

    const existingIndex = registry.plugins.findIndex(p => p.id === res.id);
    const pluginEntry = {
      id: res.id,
      name: res.name,
      version: res.version,
      author: res.author,
      description: res.description,
      extensions: res.extensions,
      entry: res.entry,
      min_peekit_version: '1.0.0',
      download_url: downloadUrl,
      github_release_url: releaseUrl,
      size_kb: res.sizeKb,
      sha256: res.sha256,
      icon: res.icon,
      homepage: res.homepage
    };

    if (existingIndex >= 0) {
      registry.plugins[existingIndex] = pluginEntry;
    } else {
      registry.plugins.push(pluginEntry);
    }
  }

  fs.writeFileSync(registryPath, JSON.stringify(registry, null, 2) + '\n');
  console.log(`\n✓ Updated registry.json with ${results.length} plugins.`);

  // Also sync to website assets if website exists
  const websiteAssetRegistry = path.join(__dirname, 'website', 'assets', 'registry.json');
  if (fs.existsSync(path.dirname(websiteAssetRegistry))) {
    fs.writeFileSync(websiteAssetRegistry, JSON.stringify(registry, null, 2) + '\n');
    console.log(`✓ Synchronized registry.json to website/assets/registry.json`);
  }
}

function copyPackagesToWebsite(results) {
  const webPluginsDir = path.join(__dirname, 'website', 'web', 'plugins');
  if (!fs.existsSync(webPluginsDir)) {
    fs.mkdirSync(webPluginsDir, { recursive: true });
  }

  for (const res of results) {
    const dest = path.join(webPluginsDir, res.file);
    fs.copyFileSync(res.path, dest);
  }
  console.log(`✓ Copied ${results.length} packages to website/web/plugins/ for direct web download.`);
}

async function main() {
  console.log('=== PeekIt Plugin Packager (.pkit) ===\n');

  const shouldUpdateRegistry = args.includes('--update-registry');
  const shouldCopyToWebsite = args.includes('--copy-to-website') || shouldUpdateRegistry;
  const isAll = args.includes('--all') || (!args.includes('--audit') && args.filter(a => !a.startsWith('--')).length === 0);

  let targetDirs = [];

  if (isAll) {
    const pluginsDir = path.join(__dirname, 'plugins');
    if (fs.existsSync(pluginsDir)) {
      targetDirs = fs.readdirSync(pluginsDir)
        .map(d => path.join(pluginsDir, d))
        .filter(d => fs.statSync(d).isDirectory() && fs.existsSync(path.join(d, 'manifest.json')));
    }
  } else {
    targetDirs = args.filter(a => !a.startsWith('--')).map(a => path.resolve(a));
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
      console.log(`✓ Packed: ${res.name} (${res.id}) -> ${res.file} [${res.sizeKb} KB] (SHA256 verified)`);
    } catch (err) {
      console.error(`✗ Error packing ${dir}:`, err.message);
      process.exitCode = 1;
    }
  }

  if (results.length > 0) {
    console.log('\n=== Summary of Packages ===');
    console.table(results.map(r => ({
      Plugin: r.name,
      File: r.file,
      'Size (KB)': r.sizeKb,
      SHA256: r.sha256.slice(0, 16) + '...'
    })));

    console.log(`\nPackages saved in: ${outputDir}`);

    if (shouldUpdateRegistry) {
      updateRegistryFile(results);
    }
    if (shouldCopyToWebsite) {
      copyPackagesToWebsite(results);
    }
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});