---
name: bloc-patterns
description: Define BLoC and Cubit conventions, state class structures, naming rules, and testing patterns for the Twilight Chronicle Guides Flutter project.
---
# BLoC / Cubit Patterns

This skill defines the state management conventions for the Twilight Chronicle Guides project. All state management **must** use the `flutter_bloc` package. No `setState`, no `ChangeNotifier`, no `ValueNotifier`.

---

## When to Use Cubit vs Full BLoC

| Use **Cubit** when… | Use **BLoC** when… |
|---|---|
| State transitions are simple and direct | Complex event-driven flows with multiple event types |
| One method call → one state change | Events need to be transformed, debounced, or throttled |
| No need for event replay or logging | Event sourcing or detailed event logging is needed |
| CRUD operations, toggles, simple forms | Real-time streams, complex search with debounce |

**Default to Cubit** for most features in this project. Only upgrade to full BLoC when the event complexity justifies it.

---

## State Class Structure

Use **sealed classes** with `Equatable` for all state definitions.

### Naming Convention

```
<Feature>State       — sealed base class
<Feature>Initial     — initial/idle state
<Feature>Loading     — async operation in progress
<Feature>Loaded      — data successfully available
<Feature>Error       — failure state with error message
```

### Example

```dart
import 'package:equatable/equatable.dart';

/// Base state for the Counter feature.
sealed class CounterState extends Equatable {
  const CounterState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class CounterInitial extends CounterState {
  const CounterInitial();
}

/// Loading state while fetching counter data.
final class CounterLoading extends CounterState {
  const CounterLoading();
}

/// Loaded state with counter data available.
final class CounterLoaded extends CounterState {
  const CounterLoaded({required this.count});

  /// The current count value.
  final int count;

  @override
  List<Object?> get props => [count];
}

/// Error state when an operation fails.
final class CounterError extends CounterState {
  const CounterError({required this.message});

  /// Human-readable error description.
  final String message;

  @override
  List<Object?> get props => [message];
}
```

### Rules for State Classes

- Always use `const` constructors.
- Always extend `Equatable` and override `props`.
- Use `final class` for concrete states (prevents further subclassing).
- Use `sealed class` for the base (enables exhaustive `switch`).
- Include `///` docstrings on every class and public field.

---

## Event Class Structure (Full BLoC Only)

When using a full BLoC, define events as a sealed class hierarchy:

```dart
import 'package:equatable/equatable.dart';

/// Events for the Counter feature.
sealed class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

/// Increment the counter by one.
final class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

/// Reset the counter to zero.
final class CounterReset extends CounterEvent {
  const CounterReset();
}

/// Load counter data from repository.
final class CounterDataRequested extends CounterEvent {
  const CounterDataRequested();
}
```

### Event Naming Rules

- Use **past tense** for events that describe something that happened: `CounterIncremented`, `CounterReset`, `CounterDataRequested`.
- Do NOT use imperative names like `IncrementCounter` or `LoadData`.

---

## File Naming

| File | Naming | Location |
|---|---|---|
| Cubit | `<feature>_cubit.dart` | `lib/features/<feature>/presentation/` |
| BLoC | `<feature>_bloc.dart` | `lib/features/<feature>/presentation/` |
| State | `<feature>_state.dart` | `lib/features/<feature>/presentation/` |
| Event | `<feature>_event.dart` | `lib/features/<feature>/presentation/` |

### Class Naming

| Component | Pattern | Example |
|---|---|---|
| Cubit | `<Feature>Cubit` | `CounterCubit` |
| BLoC | `<Feature>Bloc` | `CounterBloc` |
| State base | `<Feature>State` | `CounterState` |
| Event base | `<Feature>Event` | `CounterEvent` |

---

## Cubit Implementation Pattern

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'counter_state.dart';
import '../../domain/repositories/counter_repository.dart';

/// Manages the state for the Counter feature.
class CounterCubit extends Cubit<CounterState> {
  CounterCubit({required this._repository})
      : super(const CounterInitial());

  final CounterRepository _repository;

  /// Loads the current counter value from the repository.
  Future<void> loadCounter() async {
    emit(const CounterLoading());
    try {
      final count = await _repository.getCount();
      emit(CounterLoaded(count: count));
    } on Exception catch (e) {
      emit(CounterError(message: e.toString()));
    }
  }

  /// Increments the counter by one.
  Future<void> increment() async {
    try {
      final newCount = await _repository.increment();
      emit(CounterLoaded(count: newCount));
    } on Exception catch (e) {
      emit(CounterError(message: e.toString()));
    }
  }
}
```

### Rules

- Repository is injected via the constructor — never instantiated inside the Cubit.
- Catch `Exception`, not `Error` (Dart errors are programming bugs and should crash).
- Use `on Exception catch (e)` instead of bare `catch (e)`.
- Always emit `Loading` before async work when the UI needs a loading indicator.
- Mark the repository field as `final` and private (`_repository`).

---

## Widget Integration Rules

### ✅ DO

```dart
// Provide Cubit at the top of the widget subtree
BlocProvider(
  create: (context) => CounterCubit(repository: getIt<CounterRepository>())
    ..loadCounter(),
  child: const CounterScreen(),
)

// Use BlocBuilder for reactive UI
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => switch (state) {
    CounterInitial() => const SizedBox.shrink(),
    CounterLoading() => const CircularProgressIndicator(),
    CounterLoaded(:final count) => Text('$count'),
    CounterError(:final message) => Text('Error: $message'),
  },
)

// Use BlocListener for side effects (navigation, snackbar, etc.)
BlocListener<CounterCubit, CounterState>(
  listener: (context, state) {
    if (state is CounterError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: const CounterView(),
)
```

### ❌ DON'T

```dart
// NEVER call methods in build()
@override
Widget build(BuildContext context) {
  context.read<CounterCubit>().loadCounter(); // ← BAD! Infinite loop!
  return const Placeholder();
}

// NEVER use setState
setState(() { count++; }); // ← FORBIDDEN

// NEVER use ChangeNotifier
class CounterModel extends ChangeNotifier { ... } // ← FORBIDDEN
```

---

## Subscription Management

If a Cubit/BLoC subscribes to streams, **always** cancel them in `close()`:

```dart
class CounterCubit extends Cubit<CounterState> {
  CounterCubit({required this._repository})
      : super(const CounterInitial()) {
    _subscription = _repository.watchCount().listen((count) {
      emit(CounterLoaded(count: count));
    });
  }

  final CounterRepository _repository;
  late final StreamSubscription<int> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
```

---

## Testing with `bloc_test`

Every Cubit and BLoC **must** have a corresponding test file using the `bloc_test` package.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  late MockCounterRepository repository;

  setUp(() {
    repository = MockCounterRepository();
  });

  group('CounterCubit', () {
    blocTest<CounterCubit, CounterState>(
      'emits [Loading, Loaded] when loadCounter succeeds',
      setUp: () {
        when(() => repository.getCount()).thenAnswer((_) async => 42);
      },
      build: () => CounterCubit(repository: repository),
      act: (cubit) => cubit.loadCounter(),
      expect: () => [
        const CounterLoading(),
        const CounterLoaded(count: 42),
      ],
    );

    blocTest<CounterCubit, CounterState>(
      'emits [Loading, Error] when loadCounter fails',
      setUp: () {
        when(() => repository.getCount()).thenThrow(Exception('fail'));
      },
      build: () => CounterCubit(repository: repository),
      act: (cubit) => cubit.loadCounter(),
      expect: () => [
        const CounterLoading(),
        isA<CounterError>(),
      ],
    );
  });
}
```

---

## Reference

See `references/cubit_template.dart` for a complete copy-paste template with Cubit, State, and test.
