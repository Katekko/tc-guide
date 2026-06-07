# Twilight Chronicle Guides — Agent Instructions

## Tech Stack
- **Frontend**: Flutter

## Architecture
- Follow feature-first architecture layering (domain, data, presentation).

## Testing Rules
- Every feature must have a mirroring test directory.
- Use golden tests for UI and blocTest for state.

## Code Style
- Follow **Effective Dart** conventions.
- Prefer `const` constructors and widgets.
- All public classes and methods must have `///` docstring comments.
- File naming: `snake_case`. Class naming: `PascalCase`. Variables: `camelCase`.
- Use Dart 3.0+ features: prefer `this._` for private named parameters in constructors.
- No hardcoded API keys — use environment variables.
- No `setState()`. Use BLoC/Cubit for all state.

## Before Writing Code
- Read the relevant `.claude/skills/` or documentation before creating new features, tests, or server endpoints.

## Hot Reload
- Whenever you finish an update in the UI code, check if the framework's MCP is available and call it to perform a Hot Reload automatically.

## Project Notes
- **No backend.** This is a Flutter-only app; there is no Serverpod/Drift layer. The `data/` layer's
  "data source" is the localized content from `AppLocalizations` (the generated ARB strings).
- **Guide pages = widgets + ARB.** Each guide page is a Flutter widget screen built once from the
  reusable guide widget kit (`features/guides/presentation/widgets/`). All text comes from ARB
  (`lib/l10n/app_*.arb`), so adding a language means translating strings only — never re-authoring
  page structure. Do **not** reintroduce markdown rendering for guide bodies.
- **Single `setState` deviation:** the hover micro-interaction in the shared `CardLink` widget
  (`core/widgets/`) is pure ephemeral UI and may use `StatefulWidget`/`setState` (or a
  `ValueNotifier`). All genuine app state (e.g. the active locale) must use Cubit.
