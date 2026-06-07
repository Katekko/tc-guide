#!/usr/bin/env node
import {existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync} from 'node:fs';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';

const BASE64_KEYS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
const BASE64_VALUES = Object.create(null);
for (let i = 0; i < BASE64_KEYS.length; i += 1) {
  BASE64_VALUES[BASE64_KEYS.charCodeAt(i)] = i;
}

const HEX = '0123456789abcdef'.split('');
const UUID_TEMPLATE = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'.split('');
const UUID_INDICES = [];
for (let i = 0; i < UUID_TEMPLATE.length; i += 1) {
  if (UUID_TEMPLATE[i] !== '-') UUID_INDICES.push(i);
}

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

function usage() {
  console.error('Usage: node tools/extract-apk-images.mjs <apk> [bundle] [out-dir]');
  console.error('Example: node tools/extract-apk-images.mjs com.burstgame.ymhx.apk bundle_hero apk-extract');
}

const [apk, bundle = 'bundle_hero', outDir = 'apk-extract'] = process.argv.slice(2);

if (!apk) {
  usage();
  process.exit(1);
}

if (!existsSync(apk)) {
  console.error(`APK not found: ${apk}`);
  process.exit(1);
}

const targetDir = join(outDir, bundle);
mkdirSync(targetDir, {recursive: true});

const pattern = `assets/assets/${bundle}/*`;
const unzip = spawnSync('unzip', ['-oq', apk, pattern, '-d', targetDir], {stdio: 'inherit'});
if (unzip.status !== 0) {
  process.exit(unzip.status ?? 1);
}

const bundleRoot = join(targetDir, 'assets', 'assets', bundle);
const configPath = join(bundleRoot, 'config.json');
if (!existsSync(configPath)) {
  console.error(`Bundle config not found after extraction: ${configPath}`);
  process.exit(1);
}

const config = JSON.parse(readFileSync(configPath, 'utf8'));
const typeNames = config.types ?? [];
const nativeRoot = join(bundleRoot, config.nativeBase ?? 'native');
const importRoot = join(bundleRoot, config.importBase ?? 'import');

function findNative(uuid) {
  const prefix = uuid.slice(0, 2);
  const dir = join(nativeRoot, prefix);
  if (!existsSync(dir)) return [];

  return readdirSync(dir)
    .filter((name) => name.startsWith(uuid))
    .map((name) => join(config.nativeBase ?? 'native', prefix, name));
}

function findImport(uuid) {
  const prefix = uuid.slice(0, 2);
  const file = join(importRoot, prefix, `${uuid}.json`);
  return existsSync(file) ? file : null;
}

function referencedNativeFiles(uuid) {
  const importFile = findImport(uuid);
  if (!importFile) return [];

  const text = readFileSync(importFile, 'utf8');
  const matches = text.match(/[A-Za-z0-9+/]{22}/g) ?? [];
  const files = new Set();

  for (const match of matches) {
    for (const file of findNative(decodeCocosUuid(match))) {
      files.add(file);
    }
  }

  return [...files];
}

const index = Object.entries(config.paths ?? {}).map(([id, entry]) => {
  const [logicalPath, typeIndex] = entry;
  const compressedUuid = config.uuids?.[Number(id)];
  const uuid = decodeCocosUuid(compressedUuid);

  const nativeFiles = new Set([
    ...findNative(uuid),
    ...referencedNativeFiles(uuid),
  ]);

  return {
    id: Number(id),
    logicalPath,
    type: typeNames[typeIndex] ?? String(typeIndex),
    compressedUuid,
    uuid,
    nativeFiles: [...nativeFiles],
  };
});

const indexPath = join(targetDir, `${bundle}-asset-index.json`);
writeFileSync(indexPath, `${JSON.stringify(index, null, 2)}\n`);

const imageCount = index.filter((entry) =>
  entry.nativeFiles.some((file) => /\.(png|jpe?g|webp)$/i.test(file)),
).length;

console.log(`Extracted ${bundle} to ${targetDir}`);
console.log(`Indexed ${index.length} assets, including ${imageCount} image-backed assets`);
console.log(`Wrote ${indexPath}`);
