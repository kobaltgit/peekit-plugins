const fs = require('fs');
const path = require('path');

const templatePath = path.join(__dirname, 'template_psd.html');
const agPsdPath = path.join(__dirname, 'ag-psd.min.js');
const outputPath = path.join(__dirname, '../plugins/peekit-plugin-psd/index.html');

console.log('Reading template:', templatePath);
const template = fs.readFileSync(templatePath, 'utf8');

console.log('Reading minified ag-psd:', agPsdPath);
const agPsdMin = fs.readFileSync(agPsdPath, 'utf8');

const placeholder = '<!-- INLINE_AG_PSD_PLACEHOLDER -->';
if (!template.includes(placeholder)) {
  throw new Error('Placeholder not found in template!');
}

const parts = template.split(placeholder);
const finalHtml = parts[0] + '<script>\n' + agPsdMin + '\n</script>' + parts[1];

fs.writeFileSync(outputPath, finalHtml, 'utf8');
console.log('Successfully created inlined index.html at:', outputPath);
console.log('File size:', (finalHtml.length / 1024).toFixed(1), 'KB');
