---
name: testing-standards
description: Enforce testing rules including test file mirroring, BLoC unit tests with bloc_test, golden tests with Alchemist, and mocking with mocktail for the Twilight Chronicle Guides project.
---
# Testing Standards

This skill defines the mandatory testing rules for the Twilight Chronicle Guides project. Every production file must have corresponding tests. No exceptions.

---

## The Mirroring Rule

> **RULE:** Every file in `lib/features/` MUST have a corresponding test file in `test/features/` with the EXACT same path structure.

### Path Mapping

```
lib/features/<feature>/<layer>/<file>.dart
→ test/features/<feature>/<layer>/<file>_test.dart
```

### Examples

| Production file | Test file |
|---|---|
| `lib/features/counter/presentation/counter_cubit.dart` | `test/features/counter/presentation/counter_cubit_test.dart` |
| `lib/features/counter/data/repositories/counter_repository_impl.dart` | `test/features/counter/data/repositories/counter_repository_impl_test.dart` |
| `lib/features/counter/domain/entities/counter_entry.dart` | `test/features/counter/domain/entities/counter_entry_test.dart` |
| `lib/features/counter/presentation/screens/counter_list_screen.dart` | `test/features/counter/presentation/screens/counter_list_screen_golden_test.dart` |

### Naming Convention

| Test type | Suffix | Example |
|---|---|---|
| Unit test (Cubit, Repository, Entity) | `_test.dart` | `counter_cubit_test.dart` |
| Golden test (Widget, Screen) | `_golden_test.dart` | `counter_card_golden_test.dart` |

---

## Test Types

### 1. Unit Tests for Cubits/BLoCs

Use the `bloc_test` package with the `blocTest()` function.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{APP_PACKAGE_NAME}}/features/counter/domain/repositories/counter_repository.dart';
import 'package:{{APP_PACKAGE_NAME}}/features/counter/presentation/counter_cubit.dart';
import 'package:{{APP_PACKAGE_NAME}}/features/counter/presentation/counter_state.dart';

class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  late MockCounterRepository mockRepository;

  setUp(() {
    mockRepository = MockCounterRepository();
  });

  group('CounterCubit', () {
    test('initial state is CounterInitial', () {
      final cubit = CounterCubit(repository: mockRepository);
      expect(cubit.state, const CounterInitial());
      cubit.close();
    });

    blocTest<CounterCubit, CounterState>(
      'emits [CounterLoading, CounterLoaded] when loadCounter succeeds',
      setUp: () {
        when(() => mockRepository.getCount())
            .thenAnswer((_) async => 42);
      },
      build: () => CounterCubit(repository: mockRepository),
      act: (cubit) => cubit.loadCounter(),
      expect: () => [
        const CounterLoading(),
        const CounterLoaded(count: 42),
      ],
      verify: (_) {
        verify(() => mockRepository.getCount()).called(1);
      },
    );

    blocTest<CounterCubit, CounterState>(
      'emits [CounterLoading, CounterError] when loadCounter fails',
      setUp: () {
        when(() => mockRepository.getCount())
            .thenThrow(Exception('Network error'));
      },
      build: () => CounterCubit(repository: mockRepository),
      act: (cubit) => cubit.loadCounter(),
      expect: () => [
        const CounterLoading(),
        isA<CounterError>(),
      ],
    );
  });
}
```

#### `blocTest()` Parameters Reference

| Parameter | Purpose |
|---|---|
| `build` | Creates the Cubit/BLoC instance |
| `setUp` | Runs before `build` — configure mocks here |
| `seed` | Sets an initial state before `act` |
| `act` | Calls the method(s) being tested |
| `expect` | List of expected emitted states (in order) |
| `verify` | Assertions that run after `expect` |
| `errors` | List of expected errors |
| `tearDown` | Cleanup after the test |

---

### 2. Unit Tests for Repositories

Mock the data sources and test the repository's coordination logic.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCounterLocalDataSource extends Mock
    implements CounterLocalDataSource {}

class MockSyncQueueService extends Mock implements SyncQueueService {}

void main() {
  late MockCounterLocalDataSource mockLocalDataSource;
  late MockSyncQueueService mockSyncQueue;
  late CounterRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockCounterLocalDataSource();
    mockSyncQueue = MockSyncQueueService();
    repository = CounterRepositoryImpl(
      localDataSource: mockLocalDataSource,
      syncQueueService: mockSyncQueue,
    );
  });

  group('createCounter', () {
    test('writes to local DB and enqueues sync operation', () async {
      // Arrange
      when(() => mockLocalDataSource.insert(any()))
          .thenAnswer((_) async => testCounterEntry);
      when(() => mockSyncQueue.enqueue(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            operation: any(named: 'operation'),
            payload: any(named: 'payload'),
          )).thenAnswer((_) async {});

      // Act
      final result = await repository.createCounter('My Counter');

      // Assert
      verify(() => mockLocalDataSource.insert(any())).called(1);
      verify(() => mockSyncQueue.enqueue(
            tableName: 'counter_entry',
            recordId: any(named: 'recordId'),
            operation: 'create',
            payload: any(named: 'payload'),
          )).called(1);
      expect(result.name, 'My Counter');
      expect(result.isSynced, false);
    });
  });
}
```

---

### 3. Golden Tests with Alchemist

Use the `alchemist` package for visual regression testing of widgets and screens.

#### Basic Structure

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:{{APP_PACKAGE_NAME}}/features/counter/presentation/widgets/counter_card.dart';

void main() {
  goldenTest(
    'CounterCard renders correctly',
    fileName: 'counter_card',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FlexColumnWidth(),
      children: [
        GoldenTestScenario(
          name: 'default state',
          child: const CounterCard(
            name: 'Push-ups',
            count: 42,
          ),
        ),
        GoldenTestScenario(
          name: 'zero count',
          child: const CounterCard(
            name: 'Meditation',
            count: 0,
          ),
        ),
        GoldenTestScenario(
          name: 'long name',
          child: const CounterCard(
            name: 'A very long counter name that might overflow',
            count: 999,
          ),
        ),
      ],
    ),
  );
}
```

#### Golden Test for Screens (with BLoC mocking)

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:{{APP_PACKAGE_NAME}}/features/counter/presentation/counter_cubit.dart';
import 'package:{{APP_PACKAGE_NAME}}/features/counter/presentation/counter_state.dart';
import 'package:{{APP_PACKAGE_NAME}}/features/counter/presentation/screens/counter_list_screen.dart';

class MockCounterCubit extends MockCubit<CounterState>
    implements CounterCubit {}

void main() {
  late MockCounterCubit mockCubit;

  setUp(() {
    mockCubit = MockCounterCubit();
  });

  goldenTest(
    'CounterListScreen renders all states',
    fileName: 'counter_list_screen',
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'loading state',
          child: _buildScreen(mockCubit, const CounterLoading()),
        ),
        GoldenTestScenario(
          name: 'loaded state',
          child: _buildScreen(
            mockCubit,
            const CounterLoaded(count: 5),
          ),
        ),
        GoldenTestScenario(
          name: 'error state',
          child: _buildScreen(
            mockCubit,
            const CounterError(message: 'Something went wrong'),
          ),
        ),
      ],
    ),
  );
}

Widget _buildScreen(MockCounterCubit cubit, CounterState state) {
  when(() => cubit.state).thenReturn(state);
  return MaterialApp(
    home: BlocProvider<CounterCubit>.value(
      value: cubit,
      child: const CounterListScreen(),
    ),
  );
}
```

#### Golden Test File Locations

| File type | Golden test location |
|---|---|
| Widget | Same path as widget, with `_golden_test.dart` suffix |
| Screen | Same path as screen, with `_golden_test.dart` suffix |

Golden image files are stored in `test/goldens/`.

---

## Alchemist Configuration

The `flutter_test_config.dart` file in the `test/` root configures Alchemist for consistent rendering across platforms.

Place this file at `test/flutter_test_config.dart`. See `references/flutter_test_config.dart` for the template.

### Generating / Updating Goldens

```bash
# Generate or update golden baseline images
flutter test --update-goldens

# Run golden tests (compare against baselines)
flutter test
```

### CI vs Platform Goldens

Alchemist supports two types of golden images:

| Type | Purpose | Generated by |
|---|---|---|
| **CI goldens** | Platform-independent, used in CI pipelines | `AlchemistConfig` with `platformGoldensConfig` disabled |
| **Platform goldens** | Platform-specific, used for local development | Default behavior |

Configure in `flutter_test_config.dart` which mode to use based on the environment.

---

## Mocking with `mocktail`

Use the `mocktail` package for all mocking. Do **not** use `mockito` or code generation.

### Creating Mocks

```dart
import 'package:mocktail/mocktail.dart';

class MockCounterRepository extends Mock implements CounterRepository {}
class MockCounterCubit extends MockCubit<CounterState>
    implements CounterCubit {}
```

### Stubbing

```dart
// Return a value
when(() => mock.getCount()).thenAnswer((_) async => 42);

// Throw an exception
when(() => mock.getCount()).thenThrow(Exception('fail'));

// Return void
when(() => mock.delete(any())).thenAnswer((_) async {});
```

### Verification

```dart
// Verify a method was called
verify(() => mock.getCount()).called(1);

// Verify a method was never called
verifyNever(() => mock.delete(any()));
```

### Registering Fallback Values

When using `any()` with custom types, register fallback values in `setUpAll`:

```dart
setUpAll(() {
  registerFallbackValue(CounterEntry(
    uuid: 'fake-uuid',
    name: 'fake',
    count: 0,
    isSynced: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ));
});
```

---

## Test Lifecycle

Always use `setUp` and `tearDown` for consistent test setup:

```dart
void main() {
  late MockCounterRepository mockRepository;
  late CounterCubit cubit;

  setUp(() {
    mockRepository = MockCounterRepository();
    cubit = CounterCubit(repository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  // ... tests
}
```

### Rules

- **`setUp`:** Create mocks and the system under test.
- **`tearDown`:** Close Cubits/BLoCs, dispose controllers.
- **`setUpAll`:** Register fallback values for `mocktail`.
- **`tearDownAll`:** Clean up shared resources.

---

## Test Coverage Expectations

| Component | Coverage requirement |
|---|---|
| Cubit/BLoC | All public methods, all state transitions |
| Repository | All public methods, success and error paths |
| Entity/Model | Equality, `props`, serialization (if applicable) |
| Widget/Screen | Golden tests for all visual states |

### What to Test in a Cubit

- Initial state is correct
- Each public method emits the expected state sequence
- Error states are emitted when repositories throw
- Stream subscriptions are properly managed

### What to Test in a Repository

- Local DB writes happen correctly
- Sync queue operations are enqueued
- Error handling when data sources fail
- Data mapping between models and entities

---

## Shared Test Helpers

Place shared test utilities in `test/helpers/`:

### `test/helpers/pump_app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  /// Pumps the given widget wrapped in a MaterialApp with the app's theme.
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        home: widget,
      ),
    );
  }
}
```

### `test/helpers/mocks.dart`

Centralize frequently-used mock classes:

```dart
import 'package:mocktail/mocktail.dart';

// Import all repository interfaces and Cubits
// class MockCounterRepository extends Mock implements CounterRepository {}
// class MockAuthRepository extends Mock implements AuthRepository {}
```

---

## Reference Files

- `references/test_template.dart` — Complete bloc_test and Alchemist golden test examples
- `references/flutter_test_config.dart` — Alchemist configuration file template
