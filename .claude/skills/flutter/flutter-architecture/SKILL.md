---
name: flutter-architecture
description: Guide the agent on feature-first folder structure, layer separation, and how to scaffold new features in the Twilight Chronicle Guides Flutter project.
---
# Flutter Architecture Guide

This skill defines the canonical architecture for the Twilight Chronicle Guides Flutter project. Follow these rules whenever creating, modifying, or reviewing code.

## Feature-First Organization

Every feature lives in its own directory under `lib/features/<feature_name>/`. Each feature directory **must** contain three subdirectories representing the Clean Architecture layers:

```
lib/features/<feature_name>/
├── data/
├── domain/
└── presentation/
```

Features are self-contained vertical slices. Cross-feature imports should go through `domain/` layer interfaces only — never import another feature's `data/` or `presentation/` code directly.

---

## Layer Responsibilities

### `data/` — Data Layer

This layer owns **how** data is fetched, stored, and transformed.

| Component | Location | Responsibility |
|---|---|---|
| Repository implementations | `data/repositories/` | Concrete classes implementing domain repository interfaces |
| Local data sources | `data/datasources/local/` | Drift (SQLite) DAOs and table definitions |
| Remote data sources | `data/datasources/remote/` | Serverpod client calls wrapped in data source classes |
| Data models / DTOs | `data/models/` | Serialization-specific models, Drift table companions, mappers to/from domain entities |

**Rules:**
- Repository implementations receive data source instances via constructor injection.
- All Drift table definitions and DAOs belong here.
- Serverpod-generated client models are mapped to domain entities in this layer.
- **No UI code** (widgets, BuildContext, colors, text styles) may appear in `data/`.

### `domain/` — Domain Layer

This layer owns **what** the app does — pure business logic with zero framework dependencies.

| Component | Location | Responsibility |
|---|---|---|
| Entities | `domain/entities/` | Plain Dart classes representing core business objects. Use `Equatable`. |
| Repository interfaces | `domain/repositories/` | Abstract classes defining data contracts |
| Use cases (optional) | `domain/usecases/` | Single-purpose classes encapsulating one business operation |

**Rules:**
- Entities must not import Flutter, Drift, or Serverpod packages.
- Repository interfaces are abstract classes — implementations live in `data/`.
- Use cases are optional. Use them when business logic involves coordinating multiple repositories or complex validation. For simple CRUD, the Cubit can call the repository directly.

### `presentation/` — Presentation Layer

This layer owns **how** things look and respond to user interaction.

| Component | Location | Responsibility |
|---|---|---|
| Screens / Pages | `presentation/screens/` | Top-level page widgets, typically one per route |
| Widgets | `presentation/widgets/` | Reusable UI components specific to this feature |
| BLoC / Cubit | `presentation/` | State management classes (`<feature>_cubit.dart`, `<feature>_state.dart`) |

**Rules:**
- **No business logic in presentation.** Cubits delegate to repositories or use cases.
- Never call `context.read<Cubit>().someMethod()` inside `build()`. Use `BlocListener` for side effects and `BlocBuilder` / `BlocSelector` for reactive UI.
- Screens receive their Cubit via `BlocProvider` at the widget tree level.

---

## `core/` Directory

Shared, cross-cutting utilities live in `lib/core/`:

```
lib/core/
├── theme/          # Material 3 theme data, color schemes (purple seed)
├── network/        # Serverpod client configuration, connectivity helpers
├── storage/        # Drift database setup, sync queue config
├── utils/          # Formatters, validators, extension methods
├── constants/      # App-wide constants
├── di/             # Dependency injection setup (GetIt or manual)
└── router/         # go_router route definitions
```

---

## Scaffolding a New Feature — Checklist

When creating a new feature named `<feature>`, follow these steps in order:

### Step 1 — Create directory structure

```
lib/features/<feature>/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── screens/
    └── widgets/
```

### Step 2 — Define domain entities

Create entity classes in `domain/entities/`. Use `Equatable`, `const` constructors, and `///` docstrings.

### Step 3 — Define repository interface

Create an abstract class in `domain/repositories/<feature>_repository.dart`.

### Step 4 — Implement data layer

1. If using local storage: define Drift tables in `data/datasources/local/`.
2. If using remote: create Serverpod endpoint wrappers in `data/datasources/remote/`.
3. Create DTOs/models in `data/models/` with mappers to domain entities.
4. Implement the repository in `data/repositories/`.

### Step 5 — Build presentation layer

1. Create the Cubit (or BLoC) and State classes in `presentation/`.
2. Create screen widgets in `presentation/screens/`.
3. Create reusable widgets in `presentation/widgets/`.

### Step 6 — Mirror in test/

Create the **exact same directory structure** under `test/features/<feature>/` and write tests for every production file.

### Step 7 — Wire up dependency injection

Register the new repository and Cubit in `lib/core/di/`.

### Step 8 — Add routing

Add the new screen to the router in `lib/core/router/`.

---

## Test Mirroring Rule

The `test/` folder **MUST** mirror the `lib/` folder structure exactly:

```
lib/features/counter/presentation/counter_cubit.dart
→ test/features/counter/presentation/counter_cubit_test.dart

lib/features/counter/data/repositories/counter_repository_impl.dart
→ test/features/counter/data/repositories/counter_repository_impl_test.dart
```

Every production file in `lib/features/` must have a corresponding `_test.dart` file at the matching path in `test/features/`. No exceptions.

---

## Code Style Reminders

- **File names:** `snake_case.dart`
- **Class names:** `PascalCase`
- **Variable names:** `camelCase`
- **Constructors:** Always use `const` when possible
- **Public APIs:** Always include `///` docstrings
- **Imports:** Use relative imports within the same feature; package imports across features

---

## Reference

See `references/folder_structure.md` for a full tree diagram showing the `lib/` and `test/` directory structure.
