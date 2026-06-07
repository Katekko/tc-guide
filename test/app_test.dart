import 'package:flutter_test/flutter_test.dart';
import 'package:tc_flutter_web/app.dart';
import 'package:tc_flutter_web/core/di/injection_container.dart';

void main() {
  setUp(setUpDependencies);
  tearDown(sl.reset);

  testWidgets('renders the home screen and navigates into a guide',
      (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // Home content.
    expect(find.text('Twilight Chronicle Guides'), findsOneWidget);
    expect(find.text('Start Here'), findsOneWidget);
    expect(find.text('Recommended Start'), findsOneWidget);

    // Navigate into the getting-started guide via the hero CTA.
    await tester.tap(find.text('Start Here'));
    await tester.pumpAndSettle();

    expect(find.text('New Player Guide'), findsWidgets);
    expect(find.text('Quick Start'), findsOneWidget);
  });
}
