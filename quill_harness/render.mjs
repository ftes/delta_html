import {JSDOM} from 'jsdom';
import fs from 'node:fs';

if (!String.prototype.replaceAll) {
  String.prototype.replaceAll = function replaceAll(search, replacement) {
    return this.split(search).join(replacement);
  };
}

function setupDom() {
  const dom = new JSDOM('<!doctype html><html><body><div id="editor"></div></body></html>', {
    pretendToBeVisual: true,
  });

  const {window} = dom;
  global.window = window;
  global.document = window.document;
  global.navigator = window.navigator;
  global.Node = window.Node;
  global.Text = window.Text;
  global.Element = window.Element;
  global.HTMLElement = window.HTMLElement;
  global.MutationObserver = window.MutationObserver;
  global.getSelection = window.getSelection.bind(window);
  global.DOMParser = window.DOMParser;
  global.getComputedStyle = window.getComputedStyle.bind(window);
  document.execCommand = () => false;
}

function normalizeSemanticHtml(html) {
  const dom = new JSDOM(`<body>${html}</body>`);
  const {document} = dom.window;

  for (const el of document.querySelectorAll('[class]')) {
    for (const className of [...el.classList]) {
      if (className.startsWith('ql-align-')) {
        el.style.setProperty('text-align', className.slice('ql-align-'.length));
        el.classList.remove(className);
        continue;
      }

      if (className === 'ql-direction-rtl') {
        el.style.setProperty('direction', 'rtl');
        el.classList.remove(className);
      }
    }

    if (el.classList.length === 0) {
      el.removeAttribute('class');
    }

    if (!el.getAttribute('style')) {
      el.removeAttribute('style');
    }
  }

  return document.body.innerHTML;
}

async function main() {
  const payload = (process.argv[2] ?? fs.readFileSync(0, 'utf8')).trim();
  if (!payload) {
    throw new Error('Expected delta JSON on stdin');
  }

  const input = JSON.parse(payload);
  const ops = Array.isArray(input) ? input : input?.ops;
  if (!Array.isArray(ops)) {
    throw new Error('Input must be a delta array or object with an ops array');
  }

  setupDom();
  const {default: Quill} = await import('quill');
  const quill = new Quill('#editor');

  quill.setContents(ops);

  const semanticHtml = quill.getSemanticHTML();

  const output = {
    normalized_ops: quill.getContents().ops,
    semantic_html: semanticHtml,
    semantic_html_normalized: normalizeSemanticHtml(semanticHtml),
    root_html: quill.root.innerHTML,
  };

  process.stdout.write(JSON.stringify(output));
}

main().catch((error) => {
  const message = error?.stack || error?.message || String(error);
  process.stderr.write(`${message}\n`);
  process.exit(1);
});
