const fs = require('fs');
const fflate = require('fflate');

// 1. Create a sample FB2 file
const sampleFb2 = `<?xml version="1.0" encoding="utf-8"?>
<FictionBook xmlns="http://www.gribuser.ru/xml/fictionbook/2.0" xmlns:l="http://www.w3.org/1999/xlink">
  <description>
    <title-info>
      <genre>sf</genre>
      <author>
        <first-name>Артур</first-name>
        <last-name>Кларк</last-name>
      </author>
      <book-title>Космическая одиссея</book-title>
      <annotation>
        <p>Легендарный научно-фантастический роман о загадочном монолите и экспедиции к Юпитеру.</p>
      </annotation>
      <date>1968</date>
      <lang>ru</lang>
    </title-info>
  </description>
  <body>
    <title>
      <p>Космическая одиссея</p>
    </title>
    <section>
      <title>
        <p>Глава 1. Доисторические времена</p>
      </title>
      <p>Засуха продолжалась уже десять миллионов лет, и эра гигантских чудовищ давно подошла к концу.</p>
      <p>Здесь, на экваторе континента, который много веков спустя назовут Африкой, борьба за существование стала особенно беспощадной.</p>
      <empty-line/>
      <p>Смотритель Луны проснулся на рассвете и поежился от утреннего холода.</p>
    </section>
    <section>
      <title>
        <p>Глава 2. Монолит</p>
      </title>
      <p>Они нашли его около пересохшего ручья — сияющий прямоугольный монолит из абсолютно черного, не отражающего свет материала.</p>
      <p>Его грани были идеальны, ни одна пылинка не приставала к его зеркальной поверхности.</p>
    </section>
  </body>
</FictionBook>`;

fs.writeFileSync('scratch/sample_book.fb2', sampleFb2, 'utf8');
console.log('Saved scratch/sample_book.fb2');

// 2. Create a minimal valid sample EPUB file using fflate
const epubFiles = {
  'mimetype': fflate.strToU8('application/epub+zip', true),
  'META-INF/container.xml': fflate.strToU8(`<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>`),
  'OEBPS/content.opf': fflate.strToU8(`<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="BookID" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Звёздный странник</dc:title>
    <dc:creator>Джек Лондон</dc:creator>
    <dc:language>ru</dc:language>
    <dc:description>Роман о силе человеческого духа и силе воображения.</dc:description>
  </metadata>
  <manifest>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="chapter1" href="ch1.xhtml" media-type="application/xhtml+xml"/>
    <item id="chapter2" href="ch2.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
  <spine toc="ncx">
    <itemref idref="chapter1"/>
    <itemref idref="chapter2"/>
  </spine>
</package>`),
  'OEBPS/toc.ncx': fflate.strToU8(`<?xml version="1.0" encoding="utf-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head><meta name="dtb:uid" content="urn:uuid:12345"/></head>
  <docTitle><text>Звёздный странник</text></docTitle>
  <navMap>
    <navPoint id="navPoint-1" playOrder="1">
      <navLabel><text>Часть первая. Смирительная рубашка</text></navLabel>
      <content src="ch1.xhtml"/>
    </navPoint>
    <navPoint id="navPoint-2" playOrder="2">
      <navLabel><text>Часть вторая. Межзвездные странствия</text></navLabel>
      <content src="ch2.xhtml"/>
    </navPoint>
  </navMap>
</ncx>`),
  'OEBPS/ch1.xhtml': fflate.strToU8(`<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Часть первая</title></head>
<body>
  <h1>Часть первая. Смирительная рубашка</h1>
  <p>Всю свою жизнь я отдавал себе отчет в других временах и других местах.</p>
  <p>Я помню иные воплощения. Я знаю, что человек не умирает со смертью тела.</p>
</body>
</html>`),
  'OEBPS/ch2.xhtml': fflate.strToU8(`<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title>Часть вторая</title></head>
<body>
  <h1>Часть вторая. Межзвездные странствия</h1>
  <p>Звезды кружились в вечном танце времени и пространства.</p>
  <p>Я шел сквозь века и цивилизации, наблюдая за рассветом и падением империй.</p>
</body>
</html>`)
};

const epubZip = fflate.zipSync(epubFiles);
fs.writeFileSync('scratch/sample_book.epub', epubZip);
console.log('Saved scratch/sample_book.epub (size:', epubZip.length, 'bytes)');
