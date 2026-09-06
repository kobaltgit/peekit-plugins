const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const templatePath = path.join(__dirname, 'template_eps.html');
const outputPath = path.join(rootDir, 'plugins', 'peekit-plugin-eps', 'index.html');

console.log('Building inlined EPS plugin...');

const pakoPath = path.join(rootDir, 'node_modules', 'pako', 'dist', 'browser', 'pako.umd.min.js');
const utifPath = path.join(rootDir, 'node_modules', 'utif', 'UTIF.js');
const udocPath = path.join(__dirname, 'lib_eps', 'UDOC.js');
const fromPsPath = path.join(__dirname, 'lib_eps', 'FromPS.js');
const toContext2dPath = path.join(__dirname, 'lib_eps', 'ToContext2D.js');

let pakoCode = fs.readFileSync(pakoPath, 'utf8');
let utifCode = fs.readFileSync(utifPath, 'utf8');
let udocCode = fs.readFileSync(udocPath, 'utf8');
let fromPsCode = fs.readFileSync(fromPsPath, 'utf8');
let toContext2dCode = fs.readFileSync(toContext2dPath, 'utf8');

// Ensure browser window globals
const bundledJs = `
  <script>
    // --- Embedded pako (zlib/inflate) ---
    (function() {
      ${pakoCode}
    })();

    // --- Embedded UTIF.js ---
    (function() {
      var module = undefined;
      var exports = undefined;
      ${utifCode}
      if (typeof UTIF !== 'undefined') window.UTIF = UTIF;
    })();

    // --- Embedded UDOC.js ---
    (function() {
      ${udocCode}
      window.UDOC = UDOC;
    })();

    // --- Embedded FromPS.js ---
    (function() {
      ${fromPsCode}
      window.FromPS = FromPS;
    })();

    // --- Embedded ToContext2D.js ---
    (function() {
      ${toContext2dCode}
      window.ToContext2D = ToContext2D;
    })();
  </script>
`;

let templateHtml = fs.readFileSync(templatePath, 'utf8');
const inlinedHtml = templateHtml.replace('<!-- INLINE_LIBRARIES_PLACEHOLDER -->', bundledJs);

fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, inlinedHtml, 'utf8');

const stat = fs.statSync(outputPath);
console.log('✓ Successfully generated:', outputPath);
console.log('  File size: ' + (stat.size / 1024).toFixed(1) + ' KB');
