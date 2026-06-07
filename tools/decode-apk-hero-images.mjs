#!/usr/bin/env node
import {existsSync, mkdirSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync} from 'node:fs';
import {basename, join, resolve} from 'node:path';
import {spawnSync} from 'node:child_process';

const ids = process.argv.slice(2);
if (ids.length === 0) {
  console.error('Usage: node tools/decode-apk-hero-images.mjs <hero-id> [hero-id ...]');
  console.error('Example: node tools/decode-apk-hero-images.mjs 55007 65014');
  process.exit(1);
}

const galleryPath = 'apk-extract/gallery/hero-gallery.json';
if (!existsSync(galleryPath)) {
  console.error('Run build-apk-hero-gallery.mjs first.');
  process.exit(1);
}

const gallery = JSON.parse(readFileSync(galleryPath, 'utf8'));
const outRoot = 'apk-extract/decoded/heroes';
mkdirSync(outRoot, {recursive: true});

function decodeBasisTexture(source, outDir, prefix) {
  mkdirSync(outDir, {recursive: true});
  const before = new Set(readdirSync(outDir));
  const result = spawnSync(
    'npx',
    ['basis_universal', '-unpack', '-no_ktx', '-file', resolve(source)],
    {cwd: outDir, encoding: 'utf8'},
  );

  if (result.status !== 0) {
    console.error(result.stdout);
    console.error(result.stderr);
    throw new Error(`basisu failed for ${source}`);
  }

  const produced = readdirSync(outDir).filter((name) => !before.has(name));
  const rgba = produced.find((name) => name.includes('_unpacked_rgba_ETC2_RGBA_'));
  const rgb = produced.find((name) => name.includes('_unpacked_rgb_RGBA32_'));
  const keep = rgba ?? rgb;

  if (!keep) {
    for (const name of produced) rmSync(join(outDir, name), {force: true});
    throw new Error(`No PNG output found for ${source}`);
  }

  const finalName = `${prefix}.png`;
  renameSync(join(outDir, keep), join(outDir, finalName));

  for (const name of produced) {
    if (name !== keep) rmSync(join(outDir, name), {force: true});
  }

  return finalName;
}

const decoded = {};

for (const id of ids) {
  const entries = gallery[id] ?? [];
  const outDir = join(outRoot, id);
  decoded[id] = [];

  for (let i = 0; i < entries.length; i += 1) {
    const entry = entries[i];
    const source = join('apk-extract/gallery', entry.src);
    if (!existsSync(source)) continue;

    const prefix = `${String(i + 1).padStart(2, '0')}-${entry.kind}-${basename(entry.logicalPath)}`.replace(/[^A-Za-z0-9._-]+/g, '_');
    const output = decodeBasisTexture(source, outDir, prefix);
    decoded[id].push({...entry, decoded: output});
  }
}

writeFileSync(join(outRoot, 'decoded-heroes.json'), `${JSON.stringify(decoded, null, 2)}\n`);
console.log(`Decoded ${Object.values(decoded).reduce((sum, items) => sum + items.length, 0)} textures to ${outRoot}`);
