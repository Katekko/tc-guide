import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tc_flutter_web/core/locale/locale_cubit.dart';

void main() {
  group('LocaleCubit', () {
    test('initial state is English', () {
      final cubit = LocaleCubit();
      expect(cubit.state, const Locale('en'));
      cubit.close();
    });

    blocTest<LocaleCubit, Locale>(
      'emits the selected locale',
      build: LocaleCubit.new,
      act: (cubit) => cubit.select(const Locale('pt', 'BR')),
      expect: () => const [Locale('pt', 'BR')],
    );

    blocTest<LocaleCubit, Locale>(
      'emits each selection in order',
      build: LocaleCubit.new,
      act: (cubit) => cubit
        ..select(const Locale('pt', 'BR'))
        ..select(const Locale('en')),
      expect: () => const [Locale('pt', 'BR'), Locale('en')],
    );
  });
}
