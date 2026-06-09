#!/usr/bin/env node
// Assemble TC *battle* unit Spine rigs (the `heros` variant — the in-gameplay
// model, NOT the `lihui` portrait) into apk-extract/spine-viewer/b<id>/ so the
// vendored Spine 3.8 web player can load them.
//
//   node tools/build-battle-spine.mjs 55007            # one hero
//   node tools/build-battle-spine.mjs 55007 65014      # several
//
// The `heros` rig is a single-page cut-out paper-doll with three facing
// directions (Z/正 front, C/侧 side, B/背 back). Texture pages are Basis
// Universal (ETC1S) and get transcoded to real PNG, matched to atlas pages by
// dimensions — identical handling to build-hero-spines.mjs.
import {
  mkdirSync, readFileSync, readdirSync, copyFileSync, renameSync, rmSync,
} from 'node:fs';
import {join, resolve} from 'node:path';
import {spawnSync} from 'node:child_process';
import {tmpdir} from 'node:os';

const ROOT = resolve('.');
const INDEX = join(ROOT, 'apk-extract/bundle_hero/bundle_hero-asset-index.json');
const NATIVE_BASE = join(ROOT, 'apk-extract/bundle_hero/assets/assets/bundle_hero');
const OUT_ROOT = join(ROOT, 'apk-extract/spine-viewer');

const items = JSON.parse(readFileSync(INDEX, 'utf8')).filter((x) => x && typeof x === 'object');

// ---- build lookups for the `heros` (battle) variant ------------------------
const skelByHero = new Map(); // id -> {bin, pngs:[native paths]}
const atlasByHero = new Map(); // id -> atlas native path
const HEROS = /resources_quality\/normal\/spines\/heros\/(\d+)\/\1$/;

for (const it of items) {
  const m = (it.logicalPath || '').match(HEROS);
  if (!m) continue;
  const id = m[1];
  const nf = it.nativeFiles || [];
  if (it.type === 'sp.SkeletonData') {
    const bin = nf.find((f) => f.endsWith('.bin'));
    const pngs = nf.filter((f) => f.endsWith('.png'));
    if (bin) skelByHero.set(id, {bin, pngs});
  } else if (it.type === 'cc.Asset') {
    const atlas = nf.find((f) => f.endsWith('.atlas'));
    if (atlas) atlasByHero.set(id, atlas);
  }
}

function pngSize(file) {
  const b = readFileSync(file);
  return `${b.readUInt32BE(16)}x${b.readUInt32BE(20)}`;
}

function atlasPages(file) {
  const lines = readFileSync(file, 'utf8').split(/\r?\n/);
  const pages = [];
  for (let i = 0; i < lines.length; i += 1) {
    const name = lines[i].trim();
    if (name.endsWith('.png')) {
      const sz = (lines[i + 1] || '').trim().match(/^size:\s*(\d+),\s*(\d+)/);
      if (sz) pages.push({name, size: `${sz[1]}x${sz[2]}`});
    }
  }
  return pages;
}

function transcodeBasis(source, outDir) {
  const before = new Set(readdirSync(outDir));
  const r = spawnSync('npx', ['--yes', 'basis_universal', '-unpack', '-no_ktx', '-file', resolve(source)],
    {cwd: outDir, encoding: 'utf8'});
  if (r.status !== 0) throw new Error(`basisu failed for ${source}\n${r.stderr || r.stdout}`);
  const produced = readdirSync(outDir).filter((n) => !before.has(n));
  const rgba = produced.find((n) => n.includes('_unpacked_rgba_ETC2_RGBA_'))
    ?? produced.find((n) => n.includes('_unpacked_rgb_RGBA32_'));
  for (const n of produced) if (n !== rgba) rmSync(join(outDir, n), {force: true});
  if (!rgba) throw new Error(`no rgba PNG produced for ${source}`);
  return join(outDir, rgba);
}

function buildHero(id) {
  const skel = skelByHero.get(id);
  const atlasNative = atlasByHero.get(id);
  if (!skel || !atlasNative) return {id, ok: false, reason: 'missing heros skeleton or atlas'};

  const outDir = join(OUT_ROOT, `b${id}`);
  rmSync(outDir, {recursive: true, force: true});
  mkdirSync(outDir, {recursive: true});

  copyFileSync(join(NATIVE_BASE, skel.bin), join(outDir, `${id}.skel`));
  const atlasOut = join(outDir, `${id}.atlas`);
  copyFileSync(join(NATIVE_BASE, atlasNative), atlasOut);

  const pages = atlasPages(atlasOut);
  const tmp = join(tmpdir(), `tc-battle-${id}`);
  rmSync(tmp, {recursive: true, force: true});
  mkdirSync(tmp, {recursive: true});

  const bySize = new Map();
  for (const p of skel.pngs) {
    const png = transcodeBasis(join(NATIVE_BASE, p), tmp);
    const sz = pngSize(png);
    if (!bySize.has(sz)) bySize.set(sz, []);
    bySize.get(sz).push(png);
  }

  let bytes = 0;
  for (const page of pages) {
    const pool = bySize.get(page.size);
    if (!pool || pool.length === 0) {
      rmSync(tmp, {recursive: true, force: true});
      return {id, ok: false, reason: `no transcoded page sized ${page.size} for ${page.name}`};
    }
    renameSync(pool.shift(), join(outDir, page.name));
    bytes += readFileSync(join(outDir, page.name)).length;
  }
  rmSync(tmp, {recursive: true, force: true});
  return {id, ok: true, pages: pages.length, kb: (bytes / 1024).toFixed(0)};
}

const ids = process.argv.slice(2);
if (ids.length === 0) {
  console.error('Usage: node tools/build-battle-spine.mjs <hero-id ...>');
  console.error(`Available heros rigs: ${[...skelByHero.keys()].filter((id) => atlasByHero.has(id)).length}`);
  process.exit(1);
}
for (const id of ids) {
  process.stdout.write(`  b${id} ... `);
  try {
    const r = buildHero(id);
    console.log(r.ok ? `ok (${r.pages} page, ${r.kb} KB) -> apk-extract/spine-viewer/b${id}/` : `SKIP (${r.reason})`);
  } catch (e) {
    console.log(`FAIL (${e.message.split('\n')[0]})`);
  }
}
