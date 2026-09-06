const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const templatePath = path.join(__dirname, 'template_ebook.html');
const outputPath = path.join(rootDir, 'plugins', 'peekit-plugin-ebook', 'index.html');

console.log('Building inlined E-Book reader plugin...');

const fflatePath = path.join(rootDir, 'node_modules', 'fflate', 'umd', 'index.js');
let fflateCode = fs.readFileSync(fflatePath, 'utf8');

const bundledJs = `
  <script>
    // --- Embedded fflate (ultra-fast ZIP / DEFLATE engine) ---
    (function() {
      var module = { exports: {} };
      var exports = module.exports;
      var define = undefined;
      ${fflateCode}
      window.fflate = module.exports && Object.keys(module.exports).length ? module.exports : (self.fflate || window.fflate);
    })();
  </script>
`;

let templateHtml = fs.readFileSync(templatePath, 'utf8');
const inlinedHtml = templateHtml.split('<!-- INLINE_FFLATE_PLACEHOLDER -->').join(bundledJs);

fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, inlinedHtml, 'utf8');

const stat = fs.statSync(outputPath);
console.log('✓ Successfully generated:', outputPath);
console.log('  File size: ' + (stat.size / 1024).toFixed(1) + ' KB');
