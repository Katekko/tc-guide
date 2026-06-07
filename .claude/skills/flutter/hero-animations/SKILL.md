---
name: hero-animations
description: How to show live Spine 3.8 hero animations (extracted from the TC APK) in the Flutter Web guide — the HeroSpineView widget, the transcode/assemble pipeline, and why spine_flutter is NOT used. Use whenever adding/regenerating hero animations or touching web/spines, web/spine_viewer.html, or tools/build-hero-spines.mjs.
---
# Hero Animations (Spine)

This skill explains how animated TC heroes are rendered in the Flutter Web app,
and the exact steps to add or regenerate them. Follow it whenever working with
hero animations.

---

## Where the animations come from

TC (`com.burstgame.ymhx`) is a **Cocos Creator** game. Hero art is **Spine 2D
skeletal animation**, exported with **Spine 3.8.84**. Each hero ships three parts
inside `apk-extract/bundle_hero`:

| Part | Format | Notes |
|------|--------|-------|
| Skeleton | `.bin` | Spine **binary** skeleton. Rename to `.skel`. |
| Atlas | `.atlas` | Text: maps body-part regions → texture page name + `size: W,H`. |
| Texture pages | `.png` (fake) | Actually **Basis Universal** (ETC1S) GPU textures with a `.png` extension. Browsers can't decode them — must be transcoded to real PNG first. |

Use the `lihui` variant (full character art); the others are
`green_lihui`/`heros`/`green_heros`. There are **97 heroes** with a `lihui` skeleton.

---

## Why NOT `spine_flutter`

**Spine runtimes are version-locked.** The official `spine_flutter` package is a
**Spine 4.x** runtime and **cannot load these 3.8 skeletons** (version-mismatch
error). `spine_flutter 0.1.x` is Dart 2-only (would force the app off Dart 3) and
JSON-only (can't read the binary `.bin`).

So we render with the **official Spine 3.8 web player** (vendored JS/CSS) inside
an **`<iframe>`**, embedded via Flutter's `HtmlElementView`. Web-only — which is
fine, this guide is Flutter Web. Do **not** reach for `spine_flutter` unless the
skeletons are first converted to 4.x (requires the paid Spine editor, per hero).

---

## Adding an animation to a hero page

The widget is **lazy by construction**: the iframe (and its textures) is only
created when the page is built. One line:

```dart
import 'package:tc_flutter_web/core/widgets/hero_spine_view.dart';

const HeroSpineView(heroId: '55007', height: 460)   // 55007 = Jeanne
```

- Optional `animation: 'Idle2'` forces a clip (default: `Idle`, else first clip).
- Hero ids are listed in `web/spines/index.json`.
- Live example: `lib/features/guides/presentation/screens/jeanne_screen.dart`.

---

## Regenerating / adding heroes (pipeline)

Requires `node` + network (`npx basis_universal` does the Basis→PNG transcode).

```bash
node tools/build-hero-spines.mjs 55007          # one hero
node tools/build-hero-spines.mjs 55007 65014    # several
node tools/build-hero-spines.mjs --all          # all 97 (~266 MB)
```

Per hero it: (1) looks up `.bin` + `.atlas` + texture UUIDs from
`apk-extract/bundle_hero/bundle_hero-asset-index.json`; (2) copies `.bin` →
`<id>.skel` and `.atlas` verbatim; (3) transcodes each Basis texture (keeping the
`_unpacked_rgba_ETC2_RGBA_` variant); (4) **matches each PNG to its atlas page by
image dimensions** (`size: W,H` == PNG width×height) and renames it to the page
name; (5) writes `web/spines/index.json`.

> The dimension match is the linchpin: the atlas names pages `55007.png`,
> `550072.png`… but source files are UUIDs. Dimensions disambiguate reliably.

---

## Project layout

```
tools/build-hero-spines.mjs        # pipeline
web/spine/spine-player.{js,css}    # vendored Spine 3.8 runtime
web/spine_viewer.html              # iframe page: ?hero=ID renders that hero
web/spines/<id>/<id>.skel|.atlas|<pageName>.png
web/spines/index.json              # { "heroes": [...] }
lib/core/widgets/hero_spine_view.dart       # conditional export (web vs stub)
lib/core/widgets/hero_spine_view_web.dart   # iframe-backed HtmlElementView
lib/core/widgets/hero_spine_view_stub.dart  # non-web no-op
apk-extract/spine-viewer/          # standalone browser viewer (debugging)
```

---

## Asset size

`web/spines/` is **~266 MB** for all 97 heroes, and is **fully regenerable** from
the APK. Prefer **gitignoring `web/spines/`** and regenerating at build/deploy
time over committing it. (A 1024px downscale option would need atlas-coordinate
rescaling — not yet implemented.)

---

## Manual reproduction (debugging)

1. From the bundle index, find the `sp.SkeletonData` at `…/spines/lihui/<id>/<id>`
   (→ `.bin` + texture PNGs) and the `cc.Asset` at the same path (→ `.atlas`).
2. Transcode textures Basis→PNG; rename `.bin`→`<id>.skel` and each PNG to the
   atlas page it matches by dimensions.
3. Serve the folder (browsers block `file://` fetch) and load with
   `spine.SpinePlayer({skelUrl, atlasUrl})`. See `apk-extract/spine-viewer/index.html`:
   `cd apk-extract/spine-viewer && python3 -m http.server 8099`.
