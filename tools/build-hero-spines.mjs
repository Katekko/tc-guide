#!/usr/bin/env node
// Assemble TC hero Spine assets (3.8) into web/spines/<id>/ so the vendored
// Spine 3.8 web player can load them at runtime.
//
//   node tools/build-hero-spines.mjs 55007            # one hero
//   node tools/build-hero-spines.mjs 55007 65014      # several
//   node tools/build-hero-spines.mjs --all            # every lihui hero
//
// For each hero we take the `lihui` (full character art) variant:
//   - skeleton .bin  -> <id>.skel
//   - .atlas         -> <id>.atlas  (verbatim; it lists page names + sizes)
//   - texture pages  -> transcoded from Basis to real PNG, renamed to the
//                       atlas page names by matching image dimensions.
import {
  existsSync, mkdirSync, readFileSync, readdirSync, copyFileSync,
  renameSync, rmSync, writeFileSync,
} from 'node:fs';
import {join, resolve, basename} from 'node:path';
import {spawnSync} from 'node:child_process';
import {tmpdir} from 'node:os';

const ROOT = resolve('.');
const INDEX = join(ROOT, 'apk-extract/bundle_hero/bundle_hero-asset-index.json');
const NATIVE_BASE = join(ROOT, 'apk-extract/bundle_hero/assets/assets/bundle_hero');
const OUT_ROOT = join(ROOT, 'web/spines');

const items = JSON.parse(readFileSync(INDEX, 'utf8')).filter((x) => x && typeof x === 'object');

// ---- build lookups for the lihui variant -----------------------------------
const skelByHero = new Map(); // id -> {bin, pngs:[native paths]}
const atlasByHero = new Map(); // id -> atlas native path
const LIHUI = /resources_quality\/normal\/spines\/lihui\/(\d+)\/\1$/;

for (const it of items) {
  const lp = it.logicalPath || '';
  const m = lp.match(LIHUI);
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

// ---- helpers ----------------------------------------------------------------
function pngSize(file) {
  // PNG: width = big-endian uint32 @16, height @20 (after 8-byte sig + IHDR len/type)
  const b = readFileSync(file);
  return `${b.readUInt32BE(16)}x${b.readUInt32BE(20)}`;
}

function atlasPages(file) {
  // Each page block starts with "<name>.png" then a "size: W,H" line.
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
  // clean the dozens of unused format variants
  for (const n of produced) if (n !== rgba) rmSync(join(outDir, n), {force: true});
  if (!rgba) throw new Error(`no rgba PNG produced for ${source}`);
  return join(outDir, rgba);
}

function buildHero(id) {
  const skel = skelByHero.get(id);
  const atlasNative = atlasByHero.get(id);
  if (!skel || !atlasNative) return {id, ok: false, reason: 'missing lihui skeleton or atlas'};

  const outDir = join(OUT_ROOT, id);
  rmSync(outDir, {recursive: true, force: true});
  mkdirSync(outDir, {recursive: true});

  // skeleton + atlas
  copyFileSync(join(NATIVE_BASE, skel.bin), join(outDir, `${id}.skel`));
  const atlasOut = join(outDir, `${id}.atlas`);
  copyFileSync(join(NATIVE_BASE, atlasNative), atlasOut);

  const pages = atlasPages(atlasOut);
  const tmp = join(tmpdir(), `tc-spine-${id}`);
  rmSync(tmp, {recursive: true, force: true});
  mkdirSync(tmp, {recursive: true});

  // transcode every texture page, index by dimensions
  const bySize = new Map(); // "WxH" -> [files]
  for (const p of skel.pngs) {
    const png = transcodeBasis(join(NATIVE_BASE, p), tmp);
    const sz = pngSize(png);
    if (!bySize.has(sz)) bySize.set(sz, []);
    bySize.get(sz).push(png);
  }

  // assign each atlas page a transcoded PNG with matching dimensions
  let bytes = 0;
  for (const page of pages) {
    const pool = bySize.get(page.size);
    if (!pool || pool.length === 0) {
      rmSync(tmp, {recursive: true, force: true});
      return {id, ok: false, reason: `no transcoded page sized ${page.size} for ${page.name}`};
    }
    const src = pool.shift();
    const dest = join(outDir, page.name);
    renameSync(src, dest);
    bytes += readFileSync(dest).length;
  }
  rmSync(tmp, {recursive: true, force: true});
  return {id, ok: true, pages: pages.length, mb: (bytes / 1048576).toFixed(1)};
}

// ---- run --------------------------------------------------------------------
const args = process.argv.slice(2);
const ids = args.includes('--all')
  ? [...skelByHero.keys()].filter((id) => atlasByHero.has(id)).sort()
  : args;

if (ids.length === 0) {
  console.error('Usage: node tools/build-hero-spines.mjs <hero-id ...> | --all');
  console.error(`Available lihui heroes: ${[...skelByHero.keys()].filter((id) => atlasByHero.has(id)).length}`);
  process.exit(1);
}

mkdirSync(OUT_ROOT, {recursive: true});
const done = [];
let totalMb = 0;
for (const id of ids) {
  process.stdout.write(`  ${id} ... `);
  try {
    const r = buildHero(id);
    if (r.ok) { totalMb += parseFloat(r.mb); console.log(`ok (${r.pages} pages, ${r.mb} MB)`); }
    else console.log(`SKIP (${r.reason})`);
    done.push(r);
  } catch (e) {
    console.log(`FAIL (${e.message.split('\n')[0]})`);
    done.push({id, ok: false, reason: e.message});
  }
}

const heroes = done.filter((r) => r.ok).map((r) => r.id);
writeFileSync(join(OUT_ROOT, 'index.json'), `${JSON.stringify({heroes}, null, 2)}\n`);
console.log(`\nDone: ${heroes.length}/${ids.length} heroes, ~${totalMb.toFixed(0)} MB total -> web/spines/`);
