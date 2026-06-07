import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tc_flutter_web/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:tc_flutter_web/features/feedback/domain/entities/feedback_category.dart';
import 'package:tc_flutter_web/features/feedback/domain/entities/feedback_request.dart';
import 'package:tc_flutter_web/features/feedback/domain/repositories/feedback_repository.dart';

class _MockClient extends Mock implements http.Client {}

void main() {
  const request = FeedbackRequest(
    title: 'Add a Nyx guide',
    category: FeedbackCategory.feature,
    body: 'Please cover Nyx team comps.',
    email: 'player@example.com',
    pageRoute: '/docs/team-comps',
    locale: 'en',
  );

  late _MockClient client;
  late FeedbackRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(Uri()));

  setUp(() {
    client = _MockClient();
    repository = FeedbackRepositoryImpl(client: client, accessKey: 'test-key');
  });

  void stubResponse(http.Response response) {
    when(
      () => client.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => response);
  }

  test('completes when Web3Forms returns success', () async {
    stubResponse(http.Response('{"success": true}', 200));
    await expectLater(repository.send(request), completes);
  });

  test('sends the access key and reply-to email in the payload', () async {
    stubResponse(http.Response('{"success": true}', 200));
    await repository.send(request);

    final body = verify(
      () => client.post(
        any(),
        headers: any(named: 'headers'),
        body: captureAny(named: 'body'),
      ),
    ).captured.single as String;

    expect(body, contains('test-key'));
    expect(body, contains('player@example.com'));
    expect(body, contains('/docs/team-comps'));
  });

  test('throws when the API reports success: false', () async {
    stubResponse(http.Response('{"success": false, "message": "spam"}', 200));
    await expectLater(
      repository.send(request),
      throwsA(isA<FeedbackException>()),
    );
  });

  test('throws on a non-200 status code', () async {
    stubResponse(http.Response('error', 500));
    await expectLater(
      repository.send(request),
      throwsA(isA<FeedbackException>()),
    );
  });

  test('throws immediately when the access key is empty', () async {
    final unconfigured =
        FeedbackRepositoryImpl(client: client, accessKey: '');
    await expectLater(
      unconfigured.send(request),
      throwsA(isA<FeedbackException>()),
    );
    verifyNever(
      () => client.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    );
  });
}
