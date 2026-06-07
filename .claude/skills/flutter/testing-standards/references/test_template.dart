// =============================================================================
// TEMPLATE 1: Cubit Unit Test using bloc_test
// FILE: test/features/<feature>/presentation/<feature>_cubit_test.dart
// =============================================================================

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Replace these imports with your actual paths:
// import 'package:{{APP_PACKAGE_NAME}}/features/<feature>/domain/repositories/<feature>_repository.dart';
// import 'package:{{APP_PACKAGE_NAME}}/features/<feature>/presentation/<feature>_cubit.dart';
// import 'package:{{APP_PACKAGE_NAME}}/features/<feature>/presentation/<feature>_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

// class MockFeatureRepository extends Mock implements FeatureRepository {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // late MockFeatureRepository mockRepository;

  setUp(() {
    // mockRepository = MockFeatureRepository();
  });

  // group('FeatureCubit', () {
  //   // ----- Initial State -----
  //   test('initial state is FeatureInitial', () {
  //     final cubit = FeatureCubit(repository: mockRepository);
  //     expect(cubit.state, const FeatureInitial());
  //     cubit.close();
  //   });
  //
  //   // ----- Load Items: Success -----
  //   blocTest<FeatureCubit, FeatureState>(
  //     'emits [FeatureLoading, FeatureLoaded] when loadItems succeeds',
  //     setUp: () {
  //       when(() => mockRepository.getItems())
  //           .thenAnswer((_) async => ['item1', 'item2']);
  //     },
  //     build: () => FeatureCubit(repository: mockRepository),
  //     act: (cubit) => cubit.loadItems(),
  //     expect: () => [
  //       const FeatureLoading(),
  //       const FeatureLoaded(items: ['item1', 'item2']),
  //     ],
  //     verify: (_) {
  //       verify(() => mockRepository.getItems()).called(1);
  //     },
  //   );
  //
  //   // ----- Load Items: Failure -----
  //   blocTest<FeatureCubit, FeatureState>(
  //     'emits [FeatureLoading, FeatureError] when loadItems fails',
  //     setUp: () {
  //       when(() => mockRepository.getItems())
  //           .thenThrow(Exception('Database error'));
  //     },
  //     build: () => FeatureCubit(repository: mockRepository),
  //     act: (cubit) => cubit.loadItems(),
  //     expect: () => [
  //       const FeatureLoading(),
  //       isA<FeatureError>(),
  //     ],
  //   );
  //
  //   // ----- Add Item: Success -----
  //   blocTest<FeatureCubit, FeatureState>(
  //     'emits [FeatureLoaded] when addItem succeeds',
  //     setUp: () {
  //       when(() => mockRepository.addItem(any()))
  //           .thenAnswer((_) async => ['item1', 'new_item']);
  //     },
  //     build: () => FeatureCubit(repository: mockRepository),
  //     act: (cubit) => cubit.addItem('new_item'),
  //     expect: () => [
  //       const FeatureLoaded(items: ['item1', 'new_item']),
  //     ],
  //   );
  //
  //   // ----- Add Item: Failure -----
  //   blocTest<FeatureCubit, FeatureState>(
  //     'emits [FeatureError] when addItem fails',
  //     setUp: () {
  //       when(() => mockRepository.addItem(any()))
  //           .thenThrow(Exception('Write error'));
  //     },
  //     build: () => FeatureCubit(repository: mockRepository),
  //     act: (cubit) => cubit.addItem('new_item'),
  //     expect: () => [
  //       isA<FeatureError>(),
  //     ],
  //   );
  //
  //   // ----- Seeded State -----
  //   blocTest<FeatureCubit, FeatureState>(
  //     'emits [FeatureLoaded] from a seeded FeatureLoaded state',
  //     seed: () => const FeatureLoaded(items: ['existing']),
  //     setUp: () {
  //       when(() => mockRepository.addItem(any()))
  //           .thenAnswer((_) async => ['existing', 'new']);
  //     },
  //     build: () => FeatureCubit(repository: mockRepository),
  //     act: (cubit) => cubit.addItem('new'),
  //     expect: () => [
  //       const FeatureLoaded(items: ['existing', 'new']),
  //     ],
  //   );
  // });
}

// =============================================================================
// TEMPLATE 2: Alchemist Golden Test for a Widget
// FILE: test/features/<feature>/presentation/widgets/<widget>_golden_test.dart
// =============================================================================

// import 'package:alchemist/alchemist.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// import 'package:{{APP_PACKAGE_NAME}}/features/<feature>/presentation/widgets/<widget>.dart';

// void main() {
//   goldenTest(
//     '<WidgetName> renders correctly in all states',
//     fileName: '<widget_name>',
//     builder: () => GoldenTestGroup(
//       // Optional: control column width for consistent sizing
//       columnWidthBuilder: (_) => const FixedColumnWidth(300),
//       children: [
//         GoldenTestScenario(
//           name: 'default',
//           child: const WidgetName(
//             title: 'Hello',
//             value: 42,
//           ),
//         ),
//         GoldenTestScenario(
//           name: 'empty value',
//           child: const WidgetName(
//             title: 'Empty',
//             value: 0,
//           ),
//         ),
//         GoldenTestScenario(
//           name: 'long title',
//           child: const WidgetName(
//             title: 'This is a very long title that should wrap properly',
//             value: 123,
//           ),
//         ),
//         GoldenTestScenario(
//           name: 'dark theme',
//           child: Theme(
//             data: ThemeData.dark(),
//             child: const WidgetName(
//               title: 'Dark',
//               value: 7,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// =============================================================================
// TEMPLATE 3: Alchemist Golden Test for a Screen (with BLoC mocking)
// FILE: test/features/<feature>/presentation/screens/<screen>_golden_test.dart
// =============================================================================

// import 'package:alchemist/alchemist.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// import 'package:{{APP_PACKAGE_NAME}}/features/<feature>/presentation/<feature>_cubit.dart';
// import 'package:{{APP_PACKAGE_NAME}}/features/<feature>/presentation/<feature>_state.dart';
// import 'package:{{APP_PACKAGE_NAME}}/features/<feature>/presentation/screens/<screen>.dart';

// class MockFeatureCubit extends MockCubit<FeatureState>
//     implements FeatureCubit {}
//
// void main() {
//   late MockFeatureCubit mockCubit;
//
//   setUp(() {
//     mockCubit = MockFeatureCubit();
//   });
//
//   goldenTest(
//     '<ScreenName> renders all states correctly',
//     fileName: '<screen_name>',
//     builder: () => GoldenTestGroup(
//       children: [
//         GoldenTestScenario(
//           name: 'initial state',
//           child: _wrapWithBloc(mockCubit, const FeatureInitial()),
//         ),
//         GoldenTestScenario(
//           name: 'loading state',
//           child: _wrapWithBloc(mockCubit, const FeatureLoading()),
//         ),
//         GoldenTestScenario(
//           name: 'loaded state',
//           child: _wrapWithBloc(
//             mockCubit,
//             const FeatureLoaded(items: ['Item 1', 'Item 2', 'Item 3']),
//           ),
//         ),
//         GoldenTestScenario(
//           name: 'error state',
//           child: _wrapWithBloc(
//             mockCubit,
//             const FeatureError(message: 'Something went wrong'),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget _wrapWithBloc(MockFeatureCubit cubit, FeatureState state) {
//   when(() => cubit.state).thenReturn(state);
//   when(() => cubit.stream).thenAnswer((_) => Stream.value(state));
//   return MaterialApp(
//     theme: ThemeData(
//       colorSchemeSeed: Colors.purple,
//       useMaterial3: true,
//     ),
//     home: BlocProvider<FeatureCubit>.value(
//       value: cubit,
//       child: const ScreenName(),
//     ),
//   );
// }
