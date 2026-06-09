#!/usr/bin/env node
// Extract the per-mirror Soul Mirror icons from the APK.
//
// Each mirror's icon is a `cc.SpriteFrame` at
//   resources_quality/normal/UI_new/G_gongyong_dynamic/dj_icon_rune/<mirrorId>
// packed into a texture atlas (no standalone file). This resolves the frame's
// atlas + rect (same mechanism as build-apk-profile-icons.mjs), decodes the
// atlas via basis_universal when needed, and crops each icon with sharp into
//   assets/img/soul_mirrors/<mirrorId>.png
// covering both hero and Anima mirrors uniformly.
//
// Usage: node tools/build-apk-soul-mirror-icons.mjs
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
const outRoot = 'assets/img/soul_mirrors';

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
  const file = importFile(importUuid);
  if (!existsSync(file)) return null;
  const parsed = JSON.parse(readFileSync(file, 'utf8'));
  const textureKey = parsed[1]?.[0];
  const frame = parsed.flat(Infinity).find(
    (item) => item && typeof item === 'object' && Array.isArray(item.rect),
  );
  if (!textureKey || !frame) return null;
  // Atlas packers rotate frames 90° CW to pack tighter; `rotated` flags those
  // so we can rotate them back (90° CCW) after cropping. `originalSize` is the
  // untrimmed canvas — packers strip transparent margins and record this so the
  // game can re-center the sprite; we restore that padding to match in-game.
  return {
    textureKey,
    frame,
    rotated: Boolean(frame.rotated),
    originalSize: Array.isArray(frame.originalSize) ? frame.originalSize : null,
  };
}

async function readableBySharp(file) {
  try {
    await sharp.default(file).metadata();
    return true;
  } catch {
    return false;
  }
}

const atlasCache = new Map();
async function decodedAtlas(textureKey) {
  if (atlasCache.has(textureKey)) return atlasCache.get(textureKey);
  const source = nativeFileForTexture(textureKey);
  if (!source) throw new Error(`No native texture found for ${textureKey}`);

  let out;
  if (await readableBySharp(source)) {
    out = source;
  } else {
    mkdirSync(atlasOutDir, {recursive: true});
    const finalPath = join(atlasOutDir, `${safeName(textureKey)}.png`);
    if (existsSync(finalPath)) {
      out = finalPath;
    } else {
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
      out = finalPath;
    }
  }
  atlasCache.set(textureKey, out);
  return out;
}

if (!existsSync(indexPath)) {
  console.error('Run tools/extract-apk-images.mjs for resources first.');
  process.exit(1);
}

// Only ship icons for mirrors that are actually in our catalog.
const catalogPath = 'assets/data/soul_mirrors/soul_mirrors.en.json';
const catalogIds = new Set(
  JSON.parse(readFileSync(catalogPath, 'utf8')).map((m) => String(m.id)),
);

const index = JSON.parse(readFileSync(indexPath, 'utf8'));
// Start clean so removed/renamed mirrors never leave stale icons behind.
if (existsSync(outRoot)) {
  for (const f of readdirSync(outRoot)) {
    if (f.endsWith('.png')) rmSync(join(outRoot, f), {force: true});
  }
}
mkdirSync(outRoot, {recursive: true});

const done = [];
const skipped = [];

for (const entry of index) {
  const id = entry.logicalPath?.match(/\/dj_icon_rune\/(\d+)$/)?.[1];
  if (!id || !catalogIds.has(id)) continue;

  try {
    const sprite = spriteFrame(entry.uuid);
    if (!sprite) {
      skipped.push({id, reason: 'no sprite frame'});
      continue;
    }
    const atlas = await decodedAtlas(sprite.textureKey);
    // `rect` w/h are the sprite's UPRIGHT (trimmed) size. For a rotated frame
    // the atlas footprint is rotated 90°, so the region to crop has w/h swapped;
    // cropping with the unswapped dims grabs a misaligned box that clips the
    // sprite and bleeds in a neighbor. Swap, then rotate the pixels back.
    const [left, top, rw, rh] = sprite.frame.rect;
    const width = sprite.rotated ? rh : rw;
    const height = sprite.rotated ? rw : rh;
    const metadata = await sharp.default(atlas).metadata();
    if (
      left < 0 || top < 0 || width <= 0 || height <= 0 ||
      left + width > metadata.width || top + height > metadata.height
    ) {
      skipped.push({id, reason: 'rect out of bounds', rect: sprite.frame.rect});
      continue;
    }
    // Crop first (own pipeline), then rotate the packer's 90° rotation back so
    // extract/rotate ordering is unambiguous.
    let oriented = sharp.default(atlas).extract({left, top, width, height});
    if (sprite.rotated) oriented = oriented.rotate(-90);
    const orientedBuf = await oriented.png().toBuffer();
    const om = await sharp.default(orientedBuf).metadata();

    // Re-pad the trimmed sprite back onto its full (untrimmed) canvas, centered,
    // so the icon matches what the game renders instead of a tight, off-center
    // crop that the card then clips. Offsets are ≤2px so centering is faithful.
    const [canvasW, canvasH] = sprite.originalSize ?? [om.width, om.height];
    const padLeft = Math.max(0, Math.round((canvasW - om.width) / 2));
    const padTop = Math.max(0, Math.round((canvasH - om.height) / 2));
    await sharp.default({
      create: {
        width: canvasW,
        height: canvasH,
        channels: 4,
        background: {r: 0, g: 0, b: 0, alpha: 0},
      },
    })
      .composite([{input: orientedBuf, left: padLeft, top: padTop}])
      .png()
      .toFile(join(outRoot, `${id}.png`));
    done.push(id);
  } catch (error) {
    skipped.push({id, reason: String(error.message || error)});
  }
}

done.sort((a, b) => Number(a) - Number(b));
console.log(`wrote ${done.length} mirror icons to ${outRoot}`);
if (skipped.length) {
  console.log(`skipped ${skipped.length}:`);
  for (const s of skipped) console.log(' ', s.id, '-', s.reason);
}
writeFileSync(
  join(outRoot, '_manifest.json'),
  `${JSON.stringify({extracted: done, skipped}, null, 2)}\n`,
);
