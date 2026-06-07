import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tc_flutter_web/features/feedback/domain/entities/feedback_category.dart';
import 'package:tc_flutter_web/features/feedback/domain/entities/feedback_request.dart';
import 'package:tc_flutter_web/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:tc_flutter_web/features/feedback/presentation/cubit/feedback_cubit.dart';

class _MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  const request = FeedbackRequest(
    title: 'Add a Nyx guide',
    category: FeedbackCategory.feature,
    body: 'Please cover Nyx team comps.',
  );

  late _MockFeedbackRepository repository;

  setUpAll(() => registerFallbackValue(request));

  setUp(() => repository = _MockFeedbackRepository());

  test('initial state is FeedbackStatus.initial', () {
    expect(FeedbackCubit(repository).state, const FeedbackState());
  });

  blocTest<FeedbackCubit, FeedbackState>(
    'emits [submitting, success] when the repository accepts the request',
    setUp: () => when(() => repository.send(any())).thenAnswer((_) async {}),
    build: () => FeedbackCubit(repository),
    act: (cubit) => cubit.submit(request),
    expect: () => const [
      FeedbackState(status: FeedbackStatus.submitting),
      FeedbackState(status: FeedbackStatus.success),
    ],
    verify: (_) => verify(() => repository.send(request)).called(1),
  );

  blocTest<FeedbackCubit, FeedbackState>(
    'emits [submitting, failure] when the repository throws',
    setUp: () => when(() => repository.send(any()))
        .thenThrow(const FeedbackException('boom')),
    build: () => FeedbackCubit(repository),
    act: (cubit) => cubit.submit(request),
    expect: () => const [
      FeedbackState(status: FeedbackStatus.submitting),
      FeedbackState(status: FeedbackStatus.failure, error: 'boom'),
    ],
  );

  blocTest<FeedbackCubit, FeedbackState>(
    'reset returns to the initial state',
    setUp: () => when(() => repository.send(any())).thenAnswer((_) async {}),
    build: () => FeedbackCubit(repository),
    act: (cubit) async {
      await cubit.submit(request);
      cubit.reset();
    },
    skip: 2,
    expect: () => const [FeedbackState()],
  );
}
