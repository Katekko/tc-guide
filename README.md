# Twilight Chronicle Guides

A Flutter Web guide site for Twilight Chronicle, featuring game-faithful hero
detail screens, skills, stats, and grade/evolution data extracted from the game.

🌐 **Live site:** https://tcguide.gyanburuworld.com

## Features

- `go_router` route wiring with hash URL strategy (deep links work on static hosting)
- Game-faithful hero detail screens at `/#/hero/:id` with skill modals
- Per-locale hero data with a grade/evolution selector
- Spine 3.8 hero animations rendered via the Spine web player
- Flutter generated localization from ARB
- Responsive home sections for starter path, featured heroes, and guide sections

## Development

Run it locally:

```bash
flutter run -d chrome
```

Build the static web output:

```bash
flutter build web --release
```

The build output is written to `build/web`.

## Deployment

The site is hosted on **GitHub Pages** and deployed automatically by the
[`deploy.yml`](.github/workflows/deploy.yml) GitHub Actions workflow on every
push to `main`. The workflow builds the Flutter web release and publishes
`build/web` to Pages.

The custom domain is configured via the [`web/CNAME`](web/CNAME) file
(`tcguide.gyanburuworld.com`), which Flutter copies into the build output.

### DNS (GoDaddy)

A `CNAME` record points the subdomain at GitHub Pages:

| Type  | Host    | Value                  |
| ----- | ------- | ---------------------- |
| CNAME | tcguide | katekko.github.io      |
