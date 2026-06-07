#!/usr/bin/env node
import {existsSync, mkdirSync, readFileSync, writeFileSync} from 'node:fs';
import {basename, join, relative} from 'node:path';

const outDir = process.argv[2] ?? 'apk-extract/gallery';
const heroIndexPath = 'apk-extract/bundle_hero/bundle_hero-asset-index.json';
const resourcesIndexPath = 'apk-extract/resources/resources-asset-index.json';

if (!existsSync(heroIndexPath) || !existsSync(resourcesIndexPath)) {
  console.error('Run extract-apk-images.mjs for bundle_hero and resources first.');
  process.exit(1);
}

const heroIndex = JSON.parse(readFileSync(heroIndexPath, 'utf8'));
const resourcesIndex = JSON.parse(readFileSync(resourcesIndexPath, 'utf8'));
const groups = new Map();

function imagePath(bundle, nativeFile) {
  return `../${bundle}/assets/assets/${bundle}/${nativeFile}`;
}

function groupFor(id) {
  if (!groups.has(id)) groups.set(id, []);
  return groups.get(id);
}

function add(id, kind, logicalPath, file) {
  if (!id || !file || !/\.(png|jpe?g|webp)$/i.test(file)) return;
  groupFor(id).push({kind, logicalPath, src: imagePath(kind === 'hero-bundle' ? 'bundle_hero' : 'resources', file)});
}

for (const entry of heroIndex) {
  const match = entry.logicalPath.match(/spines\/(?:green_)?(?:lihui|heros)\/(\d+)/);
  if (!match) continue;
  for (const file of entry.nativeFiles) {
    add(match[1], 'hero-bundle', entry.logicalPath, file);
  }
}

for (const entry of resourcesIndex) {
  const path = entry.logicalPath;
  const match =
    path.match(/heroGrow\/heroBg\/(\d{4,6})/) ??
    path.match(/(?:green_)?js_kapaibanshenxiang\/(\d{4,6})/) ??
    path.match(/js_kapaitouxiang\/(\d{4,6})/) ??
    path.match(/js_yuanxingtouxiang\/(\d{4,6})/) ??
    path.match(/commander_bust\/(\d{4,6})/) ??
    path.match(/(?:title|icon)_res(?:_rune)?_(\d{4,6})/) ??
    path.match(/(?:dj|nt)_icon_prop\/(\d{4,8})/) ??
    path.match(/pet\/icon\d*\/(\d{4,8})/) ??
    path.match(/Y_yingxiong_dynamic\/.*?(\d{4,8})/);
  if (!match) continue;

  let id = match[1];
  if (/\/(?:bg_heroSkin|skin\/name)\//.test(path)) {
    id = id.replace(/([1-9]\d{3,4})\d$/, '$1');
  }
  for (const file of entry.nativeFiles) {
    add(id, 'resources', path, file);
  }
}

for (const [id, items] of groups) {
  const seen = new Set();
  groups.set(id, items.filter((item) => {
    const key = `${item.logicalPath}\0${item.src}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  }));
}

const sorted = [...groups.entries()]
  .filter(([, items]) => items.length > 0)
  .sort(([a], [b]) => Number(a) - Number(b));

mkdirSync(outDir, {recursive: true});

const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Twilight Chronicle APK Hero Gallery</title>
  <style>
    :root { color-scheme: dark; font-family: system-ui, sans-serif; background: #101114; color: #f0f1f5; }
    body { margin: 0; padding: 24px; }
    header { position: sticky; top: 0; z-index: 2; margin: -24px -24px 24px; padding: 16px 24px; background: rgba(16,17,20,.94); border-bottom: 1px solid #2d3038; }
    h1 { margin: 0 0 8px; font-size: 22px; }
    input { width: min(520px, 100%); box-sizing: border-box; padding: 10px 12px; border: 1px solid #3d414c; border-radius: 6px; background: #181a20; color: inherit; }
    section { margin: 0 0 30px; }
    h2 { font-size: 18px; margin: 0 0 12px; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(170px, 1fr)); gap: 12px; }
    figure { margin: 0; padding: 10px; border: 1px solid #2d3038; border-radius: 8px; background: #181a20; }
    img { display: block; width: 100%; height: 180px; object-fit: contain; background: #0b0c0f; border-radius: 4px; }
    figcaption { margin-top: 8px; font-size: 11px; color: #b7bcc9; overflow-wrap: anywhere; }
    .kind { display: inline-block; margin-bottom: 4px; color: #7fb4ff; }
  </style>
</head>
<body>
  <header>
    <h1>Twilight Chronicle APK Hero Gallery</h1>
    <input id="filter" placeholder="Filter by hero ID or path, e.g. 65017, lihui, heroBg" />
    <p>${sorted.length} hero/id groups generated from APK-extracted images.</p>
  </header>
  <main>
    ${sorted.map(([id, items]) => `
      <section data-filter="${id} ${items.map((item) => item.logicalPath).join(' ')}">
        <h2>${id} <small>(${items.length})</small></h2>
        <div class="grid">
          ${items.map((item) => `
            <figure>
              <a href="${item.src}"><img src="${item.src}" loading="lazy" alt="${id}" /></a>
              <figcaption><span class="kind">${item.kind}</span><br />${item.logicalPath}<br />${basename(item.src)}</figcaption>
            </figure>
          `).join('')}
        </div>
      </section>
    `).join('')}
  </main>
  <script>
    const input = document.querySelector('#filter');
    const sections = [...document.querySelectorAll('section')];
    input.addEventListener('input', () => {
      const q = input.value.trim().toLowerCase();
      for (const section of sections) {
        section.hidden = q && !section.dataset.filter.toLowerCase().includes(q);
      }
    });
  </script>
</body>
</html>
`;

const htmlPath = join(outDir, 'hero-gallery.html');
writeFileSync(htmlPath, html);

const manifestPath = join(outDir, 'hero-gallery.json');
writeFileSync(
  manifestPath,
  `${JSON.stringify(Object.fromEntries(sorted), null, 2)}\n`,
);

console.log(`Wrote ${relative(process.cwd(), htmlPath)}`);
console.log(`Wrote ${relative(process.cwd(), manifestPath)}`);
