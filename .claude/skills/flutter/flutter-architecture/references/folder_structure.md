# Twilight Chronicle Guides — Full Folder Structure

This document shows the canonical directory layout for the Flutter app. The `test/` tree **must** mirror `lib/` exactly.

## `lib/` Directory

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── di/
│   │   └── injection_container.dart
│   ├── network/
│   │   └── serverpod_client.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── storage/
│   │   ├── app_database.dart
│   │   └── sync_queue_table.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── color_schemes.dart
│   └── utils/
│       ├── date_formatter.dart
│       └── uuid_generator.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── local/
│   │   │   │   │   └── auth_local_datasource.dart
│   │   │   │   └── remote/
│   │   │   │       └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── auth_cubit.dart
│   │       ├── auth_state.dart
│   │       ├── screens/
│   │       │   └── login_screen.dart
│   │       └── widgets/
│   │           └── google_sign_in_button.dart
│   │
│   └── counter/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── local/
│       │   │   │   ├── counter_dao.dart
│       │   │   │   └── counter_table.dart
│       │   │   └── remote/
│       │   │       └── counter_remote_datasource.dart
│       │   ├── models/
│       │   │   └── counter_entry_model.dart
│       │   └── repositories/
│       │       └── counter_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── counter_entry.dart
│       │   └── repositories/
│       │       └── counter_repository.dart
│       └── presentation/
│           ├── counter_cubit.dart
│           ├── counter_state.dart
│           ├── screens/
│           │   ├── counter_detail_screen.dart
│           │   └── counter_list_screen.dart
│           └── widgets/
│               ├── counter_card.dart
│               └── increment_button.dart
```

## `test/` Directory (Mirrors `lib/` Exactly)

```
test/
├── core/
│   ├── constants/
│   │   └── app_constants_test.dart
│   ├── di/
│   │   └── injection_container_test.dart
│   ├── network/
│   │   └── serverpod_client_test.dart
│   ├── router/
│   │   └── app_router_test.dart
│   ├── storage/
│   │   ├── app_database_test.dart
│   │   └── sync_queue_table_test.dart
│   ├── theme/
│   │   ├── app_theme_test.dart
│   │   └── color_schemes_test.dart
│   └── utils/
│       ├── date_formatter_test.dart
│       └── uuid_generator_test.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── local/
│   │   │   │   │   └── auth_local_datasource_test.dart
│   │   │   │   └── remote/
│   │   │   │       └── auth_remote_datasource_test.dart
│   │   │   ├── models/
│   │   │   │   └── user_model_test.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl_test.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_test.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_test.dart
│   │   └── presentation/
│   │       ├── auth_cubit_test.dart
│   │       ├── screens/
│   │       │   └── login_screen_golden_test.dart
│   │       └── widgets/
│   │           └── google_sign_in_button_golden_test.dart
│   │
│   └── counter/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── local/
│       │   │   │   ├── counter_dao_test.dart
│       │   │   │   └── counter_table_test.dart
│       │   │   └── remote/
│       │   │       └── counter_remote_datasource_test.dart
│       │   ├── models/
│       │   │   └── counter_entry_model_test.dart
│       │   └── repositories/
│       │       └── counter_repository_impl_test.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── counter_entry_test.dart
│       │   └── repositories/
│       │       └── counter_repository_test.dart
│       └── presentation/
│           ├── counter_cubit_test.dart
│           ├── screens/
│           │   ├── counter_detail_screen_golden_test.dart
│           │   └── counter_list_screen_golden_test.dart
│           └── widgets/
│               ├── counter_card_golden_test.dart
│               └── increment_button_golden_test.dart
│
├── goldens/
│   └── ci/          # CI-generated golden images (Alchemist)
│
├── flutter_test_config.dart   # Alchemist global test configuration
│
└── helpers/
    ├── pump_app.dart           # Helper to pump MaterialApp wrapper
    └── mocks.dart              # Shared mock classes (mocktail)
```

## Key Rules

1. **Every** production file in `lib/features/` has a matching `_test.dart` in `test/features/`.
2. Widget and screen files get `_golden_test.dart` files for visual regression testing.
3. Cubit/BLoC files get `_test.dart` files using `bloc_test`.
4. Repository implementations get `_test.dart` files with mocked data sources.
5. The `test/goldens/` directory stores generated golden image baselines.
6. The `test/helpers/` directory contains shared test utilities.
