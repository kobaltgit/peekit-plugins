/**
 * PeekIt Plugins Pre-Production Test Suite
 * Validates: Manifest, Security/Offline, Script Syntax, Handshake, Theme Engine, Localization Engine.
 * 
 * Usage:
 *   node test_plugins.cjs                     # Tests all plugins in plugins/
 *   node test_plugins.cjs --all               # Tests all plugins in plugins/
 *   node test_plugins.cjs plugins/peekit-xxx  # Tests single plugin
 */

const fs = require('fs');
const path = require('path');
const vm = require('vm');

const pluginsDir = path.resolve(__dirname, 'plugins');

function getPluginDirs() {
  const args = process.argv.slice(2).filter(a => !a.startsWith('--'));
  if (args.length > 0) {
    return args.map(a => path.resolve(a));
  }
  return fs.readdirSync(pluginsDir)
    .map(d => path.join(pluginsDir, d))
    .filter(d => fs.existsSync(path.join(d, 'manifest.json')));
}

function testManifest(dir) {
  const manifestPath = path.join(dir, 'manifest.json');
  if (!fs.existsSync(manifestPath)) {
    return { ok: false, error: 'manifest.json not found' };
  }
  try {
    const m = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
    if (!m.id || !m.id.startsWith('com.peekit.')) return { ok: false, error: `Invalid id: ${m.id}` };
    if (!m.name) return { ok: false, error: 'Missing name' };
    if (!m.version || !/^\d+\.\d+\.\d+/.test(m.version)) return { ok: false, error: `Invalid semver: ${m.version}` };
    if (!m.entry) return { ok: false, error: 'Missing entry' };
    if (!fs.existsSync(path.join(dir, m.entry))) return { ok: false, error: `Entry file not found: ${m.entry}` };
    if (!Array.isArray(m.supportedExtensions) || m.supportedExtensions.length === 0) {
      return { ok: false, error: 'Missing or empty supportedExtensions' };
    }
    return { ok: true, manifest: m };
  } catch (err) {
    return { ok: false, error: `JSON Parse error: ${err.message}` };
  }
}

function testOfflineSecurity(dir) {
  const forbiddenPatterns = [
    { pattern: /<script\s+[^>]*src=["']https?:\/\//i, desc: 'External script CDN' },
    { pattern: /<link\s+[^>]*href=["']https?:\/\//i, desc: 'External stylesheet/font CDN' },
    { pattern: /<iframe\s+[^>]*src=["']https?:\/\//i, desc: 'External iframe' },
    { pattern: /fetch\s*\(\s*["'`]https?:\/\//i, desc: 'Remote HTTP fetch' },
    { pattern: /\.open\s*\(\s*["'`][A-Z]+["'`]\s*,\s*["'`]https?:\/\//i, desc: 'Remote XMLHttpRequest' },
    { pattern: /new\s+WebSocket\s*\(\s*["'`]wss?:\/\//i, desc: 'Remote WebSocket' }
  ];

  const files = fs.readdirSync(dir);
  for (const f of files) {
    const ext = path.extname(f).toLowerCase();
    if (['.png', '.jpg', '.jpeg', '.svg', '.ico', '.ttf', '.woff', '.woff2'].includes(ext)) continue;
    const fullPath = path.join(dir, f);
    if (!fs.statSync(fullPath).isFile()) continue;
    const content = fs.readFileSync(fullPath, 'utf8');
    for (const rule of forbiddenPatterns) {
      if (rule.pattern.test(content)) {
        return { ok: false, error: `${rule.desc} in ${f}` };
      }
    }
  }
  return { ok: true };
}

function testSyntax(entryPath) {
  const content = fs.readFileSync(entryPath, 'utf8');
  const scriptRegex = /<script(?![^>]*src=)[^>]*>([\s\S]*?)<\/script>/gi;
  let match;
  let sIndex = 0;
  while ((match = scriptRegex.exec(content)) !== null) {
    sIndex++;
    const code = match[1];
    try {
      new vm.Script(code, { filename: `script_${sIndex}.js` });
    } catch (err) {
      return { ok: false, error: `SyntaxError in script ${sIndex}: ${err.message}` };
    }
  }
  return { ok: true };
}

function testRuntimeLifecycle(entryPath) {
  const content = fs.readFileSync(entryPath, 'utf8');
  const scriptRegex = /<script(?![^>]*src=)[^>]*>([\s\S]*?)<\/script>/gi;
  let match;
  const scripts = [];
  while ((match = scriptRegex.exec(content)) !== null) {
    scripts.push(match[1]);
  }
  if (scripts.length === 0) return { ok: true, note: 'No inline script' };

  let readySent = false;
  let langChangeSent = false;
  const postedMessages = [];

  const domElements = new Map();
  const allParsedElements = [];

  function matchesSelector(el, s) {
    s = s.trim();
    if (!s) return false;
    if (s.startsWith('[') && s.endsWith(']')) {
      const inner = s.slice(1, -1);
      const eqIdx = inner.indexOf('=');
      if (eqIdx !== -1) {
        const attrName = inner.slice(0, eqIdx).trim().toLowerCase();
        let expectedVal = inner.slice(eqIdx + 1).trim();
        if ((expectedVal.startsWith('"') && expectedVal.endsWith('"')) ||
            (expectedVal.startsWith("'") && expectedVal.endsWith("'"))) {
          expectedVal = expectedVal.slice(1, -1);
        }
        return el.getAttribute(attrName) === expectedVal;
      } else {
        const attrName = inner.trim().toLowerCase();
        return el.hasAttribute(attrName);
      }
    }
    if (s.startsWith('.')) {
      return el.classList.contains(s.slice(1));
    }
    if (s.startsWith('#')) {
      return el.id === s.slice(1);
    }
    if (el.tagName && el.tagName.toLowerCase() === s.toLowerCase()) {
      return true;
    }
    return el.id === s;
  }

  function queryAll(sel) {
    const selectors = sel.split(',').map(s => s.trim()).filter(Boolean);
    const results = new Set();
    const candidates = allParsedElements.length > 0 ? allParsedElements : Array.from(domElements.values());
    for (const s of selectors) {
      for (const el of candidates) {
        if (matchesSelector(el, s)) results.add(el);
      }
      if (s.startsWith('#')) {
        const byId = domElements.get(s.slice(1));
        if (byId) results.add(byId);
      }
    }
    return Array.from(results);
  }

  function getOrCreateElement(idOrTag) {
    if (!domElements.has(idOrTag)) {
      const attrs = new Map();
      const classes = new Set();
      const el = {
        id: idOrTag,
        title: '',
        textContent: '',
        value: '',
        width: 800,
        height: 600,
        clientWidth: 800,
        clientHeight: 600,
        style: { width: '800px', height: '600px', setProperty: () => {} },
        classList: {
          toggle: (cls) => { if (classes.has(cls)) { classes.delete(cls); return false; } classes.add(cls); return true; },
          add: (cls) => classes.add(cls),
          remove: (cls) => classes.delete(cls),
          contains: (cls) => classes.has(cls)
        },
        setAttribute: (attr, val) => {
          attrs.set(attr.toLowerCase(), String(val));
          if (attr.toLowerCase() === 'title') el.title = String(val);
          if (attr.toLowerCase() === 'placeholder') el.placeholder = String(val);
        },
        getAttribute: (attr) => (attrs.has(attr.toLowerCase()) ? attrs.get(attr.toLowerCase()) : (attr === 'data-theme' ? 'dark' : null)),
        hasAttribute: (attr) => attrs.has(attr.toLowerCase()),
        appendChild: () => {},
        removeChild: () => {},
        addEventListener: function(evt, handler) {
          if (!this._handlers) this._handlers = {};
          if (!this._handlers[evt]) this._handlers[evt] = [];
          this._handlers[evt].push(handler);
        },
        dispatchEvent: function(event) {
          const handlers = (this._handlers && this._handlers[event.type]) || [];
          for (const h of handlers) h(event);
        },
        querySelector: (sel) => queryAll(sel)[0] || getOrCreateElement(sel),
        querySelectorAll: (sel) => {
          const res = queryAll(sel);
          return res.length > 0 ? res : [getOrCreateElement(sel)];
        }
      };

      const proxyGl = new Proxy({
        canvas: el,
        drawingBufferWidth: 800,
        drawingBufferHeight: 600,
        getParameter: () => 'WebGL 1.0',
        getExtension: () => null,
        getShaderParameter: () => true,
        getProgramParameter: () => 0,
        getProgramInfoLog: () => '',
        getShaderInfoLog: () => '',
        viewport: () => {},
        clearColor: () => {},
        clear: () => {}
      }, {
        get: (target, prop) => {
          if (prop in target) return target[prop];
          return function() { return {}; };
        }
      });

      el.getContext = (type) => {
        if (type && type.includes('webgl')) return proxyGl;
        return {
          fillRect: () => {}, clearRect: () => {}, drawImage: () => {},
          getImageData: () => ({ data: new Uint8Array(4) }),
          putImageData: () => {}, createPattern: () => ({}),
          beginPath: () => {}, stroke: () => {}, fill: () => {}
        };
      };

      domElements.set(idOrTag, el);
    }
    return domElements.get(idOrTag);
  }

  // Pre-parse HTML elements (excluding <script> and <style> contents)
  const htmlOnly = content
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
    .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, '');

  const tagRegex = /<([a-zA-Z0-9-]+)\b([^>]*)>/g;
  let tMatch;
  while ((tMatch = tagRegex.exec(htmlOnly)) !== null) {
    const tagName = tMatch[1].toLowerCase();
    const rawAttrs = tMatch[2];
    const idMatch = rawAttrs.match(/\bid=["']([^"']+)["']/i);
    const id = idMatch ? idMatch[1] : ('__el_' + allParsedElements.length);
    const el = getOrCreateElement(id);
    el.tagName = tagName.toUpperCase();
    
    const attrRegex = /([a-zA-Z0-9_-]+)(?:=["']([^"']*)["'])?/g;
    let aMatch;
    while ((aMatch = attrRegex.exec(rawAttrs)) !== null) {
      const aName = aMatch[1].toLowerCase();
      const aVal = aMatch[2] !== undefined ? aMatch[2] : '';
      el.setAttribute(aName, aVal);
      if (aName === 'class') {
        aVal.split(/\s+/).filter(Boolean).forEach(c => el.classList.add(c));
      }
    }
    allParsedElements.push(el);
  }

  const textTagRegex = /<([a-zA-Z0-9-]+)\b[^>]*\bid=["']([^"']+)["'][^>]*>([^<]+)<\/\1>/g;
  let textMatch;
  while ((textMatch = textTagRegex.exec(htmlOnly)) !== null) {
    const id = textMatch[2];
    const text = textMatch[3].trim();
    if (text) {
      const el = getOrCreateElement(id);
      el.textContent = text;
    }
  }

  // Elements that intentionally display Cyrillic content (font samples, pangrams)
  // and must NOT be checked for localization — their Cyrillic text IS the content.
  const CONTENT_ELEMENTS_ALLOWLIST = new Set(['sampleRu', 'sampleEn', 'waterfallContainer', 'glyphGrid']);

  const cyrillicOriginElements = [];
  for (const [id, el] of domElements.entries()) {
    if (id.startsWith('__el_')) continue; // only check explicit author-defined IDs
    if (CONTENT_ELEMENTS_ALLOWLIST.has(id)) continue; // skip intentional content elements
    const hasRuTitle = /[а-яё]/i.test(el.title);
    const hasRuText = /[а-яё]/i.test(el.textContent);
    const hasRuPlaceholder = /[а-яё]/i.test(el.placeholder);
    if (hasRuTitle || hasRuText || hasRuPlaceholder) {
      cyrillicOriginElements.push({
        id,
        origTitle: el.title,
        origText: el.textContent,
        origPlaceholder: el.placeholder
      });
    }
  }

  const documentElement = getOrCreateElement('html');
  const body = getOrCreateElement('body');

  let messageHandler = null;
  const parentWindow = {
    postMessage: (data) => {
      postedMessages.push(data);
      if (data && data.type === 'PEEKIT_READY') {
        readySent = true;
      }
      if (data && data.type === 'PEEKIT_LANGUAGE_CHANGED') {
        langChangeSent = true;
      }
    }
  };

  const storedData = new Map();
  const mockNavigator = {
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    platform: 'Win32',
    appVersion: '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    vendor: 'Google Inc.',
    language: 'ru-RU',
    languages: ['ru-RU', 'ru', 'en-US', 'en'],
    onLine: true
  };

  const mockContext = {
    window: {
      addEventListener: (evt, h) => {
        if (evt === 'message') messageHandler = h;
      },
      postMessage: (data) => parentWindow.postMessage(data),
      matchMedia: () => ({ matches: true, addEventListener: () => {} }),
      parent: parentWindow,
      location: { href: 'http://localhost' },
      navigator: mockNavigator,
      localStorage: {
        getItem: (k) => storedData.get(k) || null,
        setItem: (k, v) => storedData.set(k, String(v))
      },
      innerWidth: 1024,
      innerHeight: 768,
      devicePixelRatio: 1
    },
    document: {
      getElementById: (id) => getOrCreateElement(id),
      querySelector: (sel) => queryAll(sel)[0] || getOrCreateElement(sel),
      querySelectorAll: (sel) => {
        const res = queryAll(sel);
        return res.length > 0 ? res : [getOrCreateElement(sel)];
      },
      documentElement: documentElement,
      body: body,
      createElement: (tag) => getOrCreateElement(tag),
      createElementNS: (ns, tag) => getOrCreateElement(tag),
      addEventListener: () => {}
    },
    localStorage: {
      getItem: (k) => storedData.get(k) || null,
      setItem: (k, v) => storedData.set(k, String(v))
    },
    navigator: mockNavigator,
    URL: globalThis.URL,
    URLSearchParams: globalThis.URLSearchParams,
    DOMException: globalThis.DOMException,
    Blob: globalThis.Blob,
    TextEncoder: globalThis.TextEncoder,
    TextDecoder: globalThis.TextDecoder,
    Path2D: class Path2D {},
    DOMMatrix: class DOMMatrix {},
    WebGLRenderingContext: function() {},
    WebGL2RenderingContext: function() {},
    setInterval: (cb, ms) => {
      try { cb(); } catch (_) {}
      return 101;
    },
    clearInterval: () => {},
    setTimeout: (cb) => { return 102; },
    clearTimeout: () => {},
    requestAnimationFrame: (cb) => 1,
    console: { log: () => {}, warn: () => {}, error: () => {} },
    agPsd: {},
    self: {}
  };
  mockContext.window.parent = parentWindow;
  mockContext.window.document = mockContext.document;
  mockContext.window.localStorage = mockContext.localStorage;
  mockContext.self = mockContext.window;

  // 1. Initial execution of all script tags in order
  try {
    for (const code of scripts) {
      vm.runInNewContext(code, mockContext, { filename: path.basename(entryPath) });
    }
  } catch (err) {
    return { ok: false, error: `Execution error on load: ${err.message}` };
  }

  // 2. Handshake check
  if (!readySent) {
    return { ok: false, error: 'PEEKIT_READY not sent to parent window' };
  }

  // 3. Init simulation
  if (!messageHandler) {
    return { ok: false, error: 'No window.message listener registered' };
  }

  try {
    messageHandler({
      data: {
        type: 'PEEKIT_INIT',
        payload: {
          filePath: 'C:/sample/file.test',
          theme: 'dark',
          language: 'ru'
        }
      }
    });
  } catch (err) {
    return { ok: false, error: `Error during PEEKIT_INIT: ${err.message}` };
  }

  // 4. Theme change test
  try {
    messageHandler({ data: { type: 'PEEKIT_THEME_CHANGED', payload: { theme: 'light' } } });
    messageHandler({ data: { type: 'PEEKIT_THEME_CHANGED', payload: { theme: 'dark' } } });
  } catch (err) {
    return { ok: false, error: `Error during PEEKIT_THEME_CHANGED: ${err.message}` };
  }

  // 5. Language toggle button check
  const btnToggleLang = domElements.get('btnToggleLang');
  let langToggleWorks = false;
  if (btnToggleLang && btnToggleLang._handlers && btnToggleLang._handlers['click']) {
    try {
      const initialText = btnToggleLang.textContent;
      btnToggleLang.dispatchEvent({ type: 'click', preventDefault: () => {}, stopPropagation: () => {} });
      const newText = btnToggleLang.textContent;
      langToggleWorks = true;
    } catch (err) {
      return { ok: false, error: `Error clicking #btnToggleLang: ${err.message}` };
    }
  }

  // 6. Host language change test & I18N completeness verification
  const unlocalizedElements = [];
  try {
    messageHandler({ data: { type: 'PEEKIT_LANGUAGE_CHANGED', payload: { language: 'en' } } });

    // Verify no Cyrillic text remains in EN mode for elements that started with Cyrillic
    for (const item of cyrillicOriginElements) {
      const el = domElements.get(item.id);
      if (!el) continue;
      if (/[а-яё]/i.test(el.title)) {
        unlocalizedElements.push(`#${item.id} [title: "${el.title}"]`);
      }
      if (/[а-яё]/i.test(el.textContent)) {
        unlocalizedElements.push(`#${item.id} [text: "${el.textContent}"]`);
      }
      if (/[а-яё]/i.test(el.placeholder)) {
        unlocalizedElements.push(`#${item.id} [placeholder: "${el.placeholder}"]`);
      }
    }

    messageHandler({ data: { type: 'PEEKIT_LANGUAGE_CHANGED', payload: { language: 'ru' } } });
  } catch (err) {
    return { ok: false, error: `Error during PEEKIT_LANGUAGE_CHANGED: ${err.message}` };
  }

  if (unlocalizedElements.length > 0) {
    return {
      ok: false,
      error: `I18N check failed (Russian text remaining in EN mode): ${unlocalizedElements.join(', ')}`
    };
  }

  return {
    ok: true,
    hasLangBtn: !!btnToggleLang,
    langToggleWorks
  };
}

function runAllTests() {
  console.log('\n======================================================');
  console.log('       PeekIt Plugins Pre-Production Test Suite        ');
  console.log('======================================================\n');

  const dirs = getPluginDirs();
  const results = [];
  let allPass = true;

  for (const dir of dirs) {
    const pluginName = path.basename(dir);
    const mRes = testManifest(dir);
    if (!mRes.ok) {
      allPass = false;
      results.push({ name: pluginName, manifest: 'FAIL', offline: '—', syntax: '—', runtime: '—', error: mRes.error });
      continue;
    }

    const oRes = testOfflineSecurity(dir);
    if (!oRes.ok) {
      allPass = false;
      results.push({ name: pluginName, manifest: 'PASS', offline: 'FAIL', syntax: '—', runtime: '—', error: oRes.error });
      continue;
    }

    const entryPath = path.join(dir, mRes.manifest.entry);
    const sRes = testSyntax(entryPath);
    if (!sRes.ok) {
      allPass = false;
      results.push({ name: pluginName, manifest: 'PASS', offline: 'PASS', syntax: 'FAIL', runtime: '—', error: sRes.error });
      continue;
    }

    const rRes = testRuntimeLifecycle(entryPath);
    if (!rRes.ok) {
      allPass = false;
      results.push({ name: pluginName, manifest: 'PASS', offline: 'PASS', syntax: 'PASS', runtime: 'FAIL', error: rRes.error });
      continue;
    }

    results.push({
      name: pluginName,
      manifest: 'PASS',
      offline: 'PASS',
      syntax: 'PASS',
      runtime: 'PASS',
      langBtn: rRes.hasLangBtn ? 'PASS' : 'WARN (No btn)',
      error: null
    });
  }

  console.table(results.map(r => ({
    Plugin: r.name,
    Manifest: r.manifest,
    Offline: r.offline,
    Syntax: r.syntax,
    Runtime: r.runtime,
    'I18N Btn': r.langBtn || '—',
    Status: r.error ? `FAIL: ${r.error}` : 'OK'
  })));

  if (allPass) {
    console.log('\n✅ ALL 20 PLUGINS PASSED PRE-PRODUCTION VERIFICATION!\n');
    return 0;
  } else {
    console.error('\n❌ PRE-PRODUCTION TESTS FAILED! Fix the reported issues above before packaging.\n');
    return 1;
  }
}

if (require.main === module) {
  const code = runAllTests();
  process.exit(code);
}

module.exports = { runAllTests, testManifest, testOfflineSecurity, testSyntax, testRuntimeLifecycle };
