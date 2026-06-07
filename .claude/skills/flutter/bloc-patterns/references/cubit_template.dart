// =============================================================================
// FILE: lib/features/<feature>/presentation/<feature>_state.dart
// =============================================================================

import 'package:equatable/equatable.dart';

/// Base state for the <Feature> feature.
sealed class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
final class FeatureInitial extends FeatureState {
  const FeatureInitial();
}

/// Loading state while fetching data.
final class FeatureLoading extends FeatureState {
  const FeatureLoading();
}

/// Loaded state with data available.
final class FeatureLoaded extends FeatureState {
  const FeatureLoaded({required this.items});

  /// The loaded data items.
  final List<String> items;

  @override
  List<Object?> get props => [items];
}

/// Error state when an operation fails.
final class FeatureError extends FeatureState {
  const FeatureError({required this.message});

  /// Human-readable error description.
  final String message;

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// FILE: lib/features/<feature>/presentation/<feature>_cubit.dart
// =============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

// import '<feature>_state.dart';
// import '../../domain/repositories/<feature>_repository.dart';

/// Repository interface — lives in domain/repositories/.
abstract class FeatureRepository {
  /// Fetches all items.
  Future<List<String>> getItems();

  /// Adds a new item and returns the updated list.
  Future<List<String>> addItem(String item);
}

/// Manages the state for the <Feature> feature.
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit({required this._repository})
      : super(const FeatureInitial());

  final FeatureRepository _repository;

  /// Loads all items from the repository.
  Future<void> loadItems() async {
    emit(const FeatureLoading());
    try {
      final items = await _repository.getItems();
      emit(FeatureLoaded(items: items));
    } on Exception catch (e) {
      emit(FeatureError(message: e.toString()));
    }
  }

  /// Adds a new item.
  Future<void> addItem(String item) async {
    try {
      final items = await _repository.addItem(item);
      emit(FeatureLoaded(items: items));
    } on Exception catch (e) {
      emit(FeatureError(message: e.toString()));
    }
  }
}

// =============================================================================
// FILE: test/features/<feature>/presentation/<feature>_cubit_test.dart
// =============================================================================

// import 'package:bloc_test/bloc_test.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';

// Uncomment the imports above and the test body below in a real test file.

/*
class MockFeatureRepository extends Mock implements FeatureRepository {}

void main() {
  late MockFeatureRepository repository;

  setUp(() {
    repository = MockFeatureRepository();
  });

  group('FeatureCubit', () {
    test('initial state is FeatureInitial', () {
      final cubit = FeatureCubit(repository: repository);
      expect(cubit.state, const FeatureInitial());
      cubit.close();
    });

    blocTest<FeatureCubit, FeatureState>(
      'emits [FeatureLoading, FeatureLoaded] when loadItems succeeds',
      setUp: () {
        when(() => repository.getItems())
            .thenAnswer((_) async => ['item1', 'item2']);
      },
      build: () => FeatureCubit(repository: repository),
      act: (cubit) => cubit.loadItems(),
      expect: () => [
        const FeatureLoading(),
        const FeatureLoaded(items: ['item1', 'item2']),
      ],
      verify: (_) {
        verify(() => repository.getItems()).called(1);
      },
    );

    blocTest<FeatureCubit, FeatureState>(
      'emits [FeatureLoading, FeatureError] when loadItems fails',
      setUp: () {
        when(() => repository.getItems())
            .thenThrow(Exception('Network error'));
      },
      build: () => FeatureCubit(repository: repository),
      act: (cubit) => cubit.loadItems(),
      expect: () => [
        const FeatureLoading(),
        isA<FeatureError>(),
      ],
    );

    blocTest<FeatureCubit, FeatureState>(
      'emits [FeatureLoaded] when addItem succeeds',
      setUp: () {
        when(() => repository.addItem(any()))
            .thenAnswer((_) async => ['item1', 'new_item']);
      },
      build: () => FeatureCubit(repository: repository),
      act: (cubit) => cubit.addItem('new_item'),
      expect: () => [
        const FeatureLoaded(items: ['item1', 'new_item']),
      ],
    );
  });
}
*/
