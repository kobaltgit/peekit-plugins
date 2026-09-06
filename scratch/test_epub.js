const fs = require('fs');
const fflate = require('fflate');

const buf = fs.readFileSync('D:/Users/Kobalt/Documents/Verber_Muravi_1_Muravi.616473.fb2.epub');
const unzipped = fflate.unzipSync(new Uint8Array(buf));
const opf = fflate.strFromU8(unzipped['OPS/content.opf']);

const manifest = {};
const itemMatches = opf.match(/<item\b[^>]*\/?>/g) || [];
for (const itemTag of itemMatches) {
  const idMatch = itemTag.match(/id="([^"]+)"/);
  const hrefMatch = itemTag.match(/href="([^"]+)"/);
  const mediaMatch = itemTag.match(/media-type="([^"]+)"/);
  if (idMatch && hrefMatch) {
    manifest[idMatch[1]] = { href: 'OPS/' + hrefMatch[1], mediaType: mediaMatch ? mediaMatch[1] : '' };
  }
}

const spineMatches = opf.match(/<itemref\b[^>]*\/?>/g) || [];
const spineItems = [];
for (const refTag of spineMatches) {
  const idrefMatch = refTag.match(/idref="([^"]+)"/);
  if (idrefMatch && manifest[idrefMatch[1]]) {
    spineItems.push(manifest[idrefMatch[1]]);
  }
}

// NCX toc
const ncxItem = Object.values(manifest).find(m => m.mediaType === 'application/x-dtbncx+xml');
const tocTitles = {};
if (ncxItem && unzipped[ncxItem.href]) {
  const ncx = fflate.strFromU8(unzipped[ncxItem.href]);
  const navPoints = ncx.match(/<navPoint\b[\s\S]*?<\/navPoint>/gi) || [];
  for (const np of navPoints) {
    const textM = np.match(/<text>([\s\S]*?)<\/text>/i);
    const srcM = np.match(/<content[^>]*src="([^"]+)"/i);
    if (textM && srcM) {
      const fullSrc = 'OPS/' + srcM[1].split('#')[0];
      tocTitles[fullSrc] = textM[1].trim();
    }
  }
}

console.log('TOC titles found in NCX:');
console.log(tocTitles);

console.log('\n--- Chapters parsed ---');
spineItems.forEach((sp, idx) => {
  const fileBytes = unzipped[sp.href];
  if (!fileBytes) return;
  const xhtml = fflate.strFromU8(fileBytes);
  
  let bodyHtml = '';
  const bodyMatch = xhtml.match(/<body[^>]*>([\s\S]*?)<\/body>/i);
  bodyHtml = bodyMatch ? bodyMatch[1] : xhtml;

  let title = tocTitles[sp.href];
  if (!title) {
    // Try semantic headings in bodyHtml
    const hMatch = bodyHtml.match(/<(?:h[1-4]|div class="title[^"]*"|p class="title[^"]*")[^>]*>([\s\S]*?)<\/(?:h[1-4]|div|p)>/i);
    if (hMatch) {
      title = hMatch[1].replace(/<[^>]+>/g, '').trim().replace(/\s+/g, ' ');
    }
  }
  if (!title) {
    if (sp.href.toLowerCase().includes('cover') || bodyHtml.includes('<svg') || bodyHtml.includes('<image')) {
      title = 'Обложка';
    } else if (bodyHtml.includes('class="epigraph"')) {
      title = 'Эпиграф';
    } else {
      title = 'Раздел ' + (idx + 1);
    }
  }

  const textPreview = bodyHtml.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 50);
  console.log(`[${idx + 1}] "${title}" (length: ${bodyHtml.length} b): "${textPreview}"`);
});
