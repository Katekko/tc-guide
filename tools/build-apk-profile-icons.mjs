#!/usr/bin/env node
import {existsSync, mkdirSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync} from 'node:fs';
import {basename, join, resolve} from 'node:path';
import {spawnSync} from 'node:child_process';

const sharp = await import('../apk-extract/image-tools/node_modules/sharp/lib/index.js');

const BASE64_KEYS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
const BASE64_VALUES = Object.create(null);
for (let i = 0; i < BASE64_KEYS.length; i += 1) BASE64_VALUES[BASE64_KEYS.charCodeAt(i)] = i;

const HEX = '0123456789abcdef'.split('');
const UUID_TEMPLATE = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'.split('');
const UUID_INDICES = [];
for (let i = 0; i < UUID_TEMPLATE.length; i += 1) {
  if (UUID_TEMPLATE[i] !== '-') UUID_INDICES.push(i);
}

const resourcesRoot = 'apk-extract/resources/assets/assets/resources';
const indexPath = 'apk-extract/resources/resources-asset-index.json';
const atlasOutDir = 'apk-extract/decoded/profile-atlases';
const outRoot = process.argv[2] ?? 'static/apk-assets/profile-icons';

function decodeCocosUuid(value) {
  if (typeof value !== 'string' || value.length !== 22) return value;

  const out = UUID_TEMPLATE.slice();
  out[0] = value[0];
  out[1] = value[1];

  for (let i = 2, j = 2; i < 22; i += 2) {
    const lhs = BASE64_VALUES[value.charCodeAt(i)];
    const rhs = BASE64_VALUES[value.charCodeAt(i + 1)];
    out[UUID_INDICES[j++]] = HEX[lhs >> 2];
    out[UUID_INDICES[j++]] = HEX[((lhs & 3) << 2) | (rhs >> 4)];
    out[UUID_INDICES[j++]] = HEX[rhs & 0xf];
  }

  return out.join('');
}

function safeName(value) {
  return value.replace(/[^A-Za-z0-9._-]+/g, '_');
}

function importFile(uuid) {
  return join(resourcesRoot, 'import', uuid.slice(0, 2), `${uuid}.json`);
}

function nativeFileForTexture(textureKey) {
  const uuid = decodeCocosUuid(textureKey);
  const dir = join(resourcesRoot, 'native', uuid.slice(0, 2));
  if (!existsSync(dir)) return null;

  const file = readdirSync(dir).find((name) => name.startsWith(uuid));
  return file ? join(dir, file) : null;
}

function spriteFrame(importUuid) {
  const parsed = JSON.parse(readFileSync(importFile(importUuid), 'utf8'));
  const textureKey = parsed[1]?.[0];
  const frame = parsed.flat(Infinity).find((item) => item && typeof item === 'object' && Array.isArray(item.rect));
  if (!textureKey || !frame) return null;
  return {textureKey, frame};
}

async function readableBySharp(file) {
  try {
    await sharp.default(file).metadata();
    return true;
  } catch {
    return false;
  }
}

async function decodedAtlas(textureKey) {
  const source = nativeFileForTexture(textureKey);
  if (!source) throw new Error(`No native texture found for ${textureKey}`);

  if (await readableBySharp(source)) return source;

  mkdirSync(atlasOutDir, {recursive: true});
  const finalPath = join(atlasOutDir, `${safeName(textureKey)}.png`);
  if (existsSync(finalPath)) return finalPath;

  const before = new Set(readdirSync(atlasOutDir));
  const result = spawnSync(
    'npx',
    ['basis_universal', '-unpack', '-no_ktx', '-file', resolve(source)],
    {cwd: atlasOutDir, encoding: 'utf8'},
  );

  if (result.status !== 0) {
    throw new Error(`basis_universal failed for ${source}\n${result.stderr || result.stdout}`);
  }

  const produced = readdirSync(atlasOutDir).filter((name) => !before.has(name));
  const keep =
    produced.find((name) => name.includes('_unpacked_rgba_ETC2_RGBA_')) ??
    produced.find((name) => name.includes('_unpacked_rgb_RGBA32_')) ??
    produced.find((name) => name.endsWith('.png'));

  if (!keep) throw new Error(`No decoded PNG produced for ${source}`);

  renameSync(join(atlasOutDir, keep), finalPath);
  for (const name of produced) {
    if (name !== keep) rmSync(join(atlasOutDir, name), {force: true});
  }

  return finalPath;
}

function profileKind(logicalPath) {
  if (logicalPath.includes('/js_kapaitouxiang/')) return 'square';
  if (logicalPath.includes('/js_yuanxingtouxiang/')) return 'round';
  return null;
}

function profileId(logicalPath) {
  return logicalPath.match(/\/js_(?:kapai|yuanxing)touxiang\/(\d+)/)?.[1] ?? null;
}

function htmlEscape(value) {
  return value.replace(/[&<>"']/g, (char) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  })[char]);
}

if (!existsSync(indexPath)) {
  console.error('Run tools/extract-apk-images.mjs for resources first.');
  process.exit(1);
}

const index = JSON.parse(readFileSync(indexPath, 'utf8'));
const profiles = [];
const skipped = [];

mkdirSync(outRoot, {recursive: true});

for (const entry of index) {
  const kind = profileKind(entry.logicalPath);
  const id = profileId(entry.logicalPath);
  if (!kind || !id) continue;

  const sprite = spriteFrame(entry.uuid);
  if (!sprite) continue;

  const atlas = await decodedAtlas(sprite.textureKey);
  const [left, top, width, height] = sprite.frame.rect;
  const metadata = await sharp.default(atlas).metadata();
  if (
    left < 0 ||
    top < 0 ||
    width <= 0 ||
    height <= 0 ||
    left + width > metadata.width ||
    top + height > metadata.height
  ) {
    skipped.push({
      id,
      kind,
      logicalPath: entry.logicalPath,
      atlas: basename(atlas),
      atlasSize: [metadata.width, metadata.height],
      rect: sprite.frame.rect,
    });
    continue;
  }

  const outDir = join(outRoot, kind);
  const filename = `${id}.png`;
  const output = join(outDir, filename);
  mkdirSync(outDir, {recursive: true});

  await sharp.default(atlas)
    .extract({left, top, width, height})
    .png()
    .toFile(output);

  profiles.push({
    id,
    kind,
    path: `${kind}/${filename}`,
    logicalPath: entry.logicalPath,
    atlas: basename(atlas),
    rect: sprite.frame.rect,
  });
}

profiles.sort((a, b) => Number(a.id) - Number(b.id) || a.kind.localeCompare(b.kind));

writeFileSync(join(outRoot, 'profile-icons.json'), `${JSON.stringify(profiles, null, 2)}\n`);
writeFileSync(join(outRoot, 'profile-icons-skipped.json'), `${JSON.stringify(skipped, null, 2)}\n`);

const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>APK Profile Icons</title>
  <style>
    :root { color-scheme: dark; font-family: system-ui, sans-serif; background: #101114; color: #f1f3f7; }
    body { margin: 0; padding: 20px; }
    header { position: sticky; top: 0; z-index: 2; margin: -20px -20px 20px; padding: 16px 20px; background: rgba(16,17,20,.96); border-bottom: 1px solid #30343d; }
    h1 { margin: 0 0 10px; font-size: 22px; }
    input { width: min(520px, 100%); box-sizing: border-box; padding: 10px 12px; border: 1px solid #414650; border-radius: 6px; background: #181b21; color: inherit; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 12px; }
    figure { margin: 0; padding: 10px; border: 1px solid #30343d; border-radius: 8px; background: #181b21; }
    img { display: block; width: 100%; height: 112px; object-fit: contain; background: #0b0c0f; border-radius: 5px; image-rendering: auto; }
    figcaption { margin-top: 8px; font-size: 12px; color: #bcc3d2; overflow-wrap: anywhere; }
    label { display: block; margin-top: 8px; font-size: 11px; color: #929aaa; }
    .nameInput { width: 100%; margin-top: 4px; box-sizing: border-box; padding: 7px 8px; border: 1px solid #414650; border-radius: 5px; background: #101318; color: inherit; }
    .actions { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; margin-top: 10px; }
    button { padding: 8px 10px; border: 1px solid #414650; border-radius: 6px; background: #222733; color: inherit; cursor: pointer; }
    textarea { width: min(760px, 100%); height: 140px; box-sizing: border-box; margin-top: 10px; padding: 10px; border: 1px solid #414650; border-radius: 6px; background: #181b21; color: inherit; font: 12px ui-monospace, SFMono-Regular, Menlo, monospace; }
    strong { color: #fff; font-size: 14px; }
    .kind { color: #85baff; }
    .muted { color: #929aaa; font-size: 13px; }
  </style>
</head>
<body>
  <header>
    <h1>APK Profile Icons</h1>
    <input id="filter" placeholder="Filter by hero ID or kind, e.g. 55001, 65014, square, round" autofocus />
    <p class="muted">${profiles.length} profile icons. Square icons are from <code>js_kapaitouxiang</code>; round icons are from <code>js_yuanxingtouxiang</code>.</p>
    <div class="actions">
      <button id="exportMap" type="button">Export name map</button>
      <button id="clearMap" type="button">Clear saved names</button>
      <span class="muted">Names are saved in this browser for this page.</span>
    </div>
    <textarea id="mapOutput" readonly placeholder="Click Export name map after naming icons."></textarea>
  </header>
  <main class="grid">
    ${profiles.map((profile) => `
      <figure data-id="${htmlEscape(profile.id)}" data-kind="${htmlEscape(profile.kind)}" data-filter="${htmlEscape(`${profile.id} ${profile.kind} ${profile.logicalPath}`)}">
        <a href="${htmlEscape(profile.path)}"><img src="${htmlEscape(profile.path)}" loading="lazy" alt="${htmlEscape(profile.id)} ${htmlEscape(profile.kind)}" /></a>
        <figcaption>
          <strong>${htmlEscape(profile.id)}</strong><br />
          <span class="kind">${htmlEscape(profile.kind)}</span><br />
          ${htmlEscape(profile.path)}
          <label>
            Hero name
            <input class="nameInput" value="" placeholder="Type hero name" autocomplete="off" />
          </label>
        </figcaption>
      </figure>
    `).join('')}
  </main>
  <script>
    const input = document.querySelector('#filter');
    const figures = [...document.querySelectorAll('figure')];
    const mapOutput = document.querySelector('#mapOutput');
    const storageKey = 'tc-apk-profile-icon-names';

    function readMap() {
      try {
        return JSON.parse(localStorage.getItem(storageKey) || '{}');
      } catch {
        return {};
      }
    }

    function writeMap(map) {
      localStorage.setItem(storageKey, JSON.stringify(map));
    }

    function applyFilters() {
      const q = input.value.trim().toLowerCase();
      for (const figure of figures) {
        const savedName = figure.querySelector('.nameInput').value.toLowerCase();
        const text = (figure.dataset.filter + ' ' + savedName).toLowerCase();
        figure.hidden = q && !text.includes(q);
      }
    }

    function exportMap() {
      const map = readMap();
      const named = Object.fromEntries(
        Object.entries(map)
          .filter(([, name]) => name.trim())
          .sort(([a], [b]) => Number(a) - Number(b)),
      );
      mapOutput.value = JSON.stringify(named, null, 2);
      mapOutput.select();
    }

    const saved = readMap();
    for (const figure of figures) {
      const nameInput = figure.querySelector('.nameInput');
      nameInput.value = saved[figure.dataset.id] || '';
      nameInput.addEventListener('input', () => {
        const map = readMap();
        const value = nameInput.value.trim();
        if (value) {
          map[figure.dataset.id] = value;
        } else {
          delete map[figure.dataset.id];
        }
        writeMap(map);

        for (const sameId of figures.filter((item) => item.dataset.id === figure.dataset.id)) {
          const sameInput = sameId.querySelector('.nameInput');
          if (sameInput !== nameInput) sameInput.value = value;
        }
        applyFilters();
      });
    }

    input.addEventListener('input', () => {
      applyFilters();
    });
    document.querySelector('#exportMap').addEventListener('click', exportMap);
    document.querySelector('#clearMap').addEventListener('click', () => {
      if (!confirm('Clear all saved hero names for this browser?')) return;
      localStorage.removeItem(storageKey);
      for (const nameInput of document.querySelectorAll('.nameInput')) nameInput.value = '';
      mapOutput.value = '';
      applyFilters();
    });
  </script>
</body>
</html>
`;

writeFileSync(join(outRoot, 'index.html'), html);

console.log(`Wrote ${profiles.length} profile icons to ${outRoot}`);
if (skipped.length > 0) console.log(`Skipped ${skipped.length} profile icons with invalid atlas crop rectangles.`);
console.log(`Open /apk-assets/profile-icons/ to browse them.`);
