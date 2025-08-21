import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Integration Test', () {
    testWidgets(
      'should show loading indicator, then display and allow scrolling',
          (WidgetTester tester) async {
        // ARRANGE: Launch the entire application.
        app.main();

        // THE FIX IS HERE: Render ONLY the first frame.
        // Instead of pumpAndSettle, a single pump() will build the widget tree
        // exactly once and then pause, allowing us to inspect the initial UI.
        await tester.pump();

        // ASSERT (Initial Loading State): Now we can reliably find the indicator.
        expect(find.byType(CircularProgressIndicator), findsOneWidget,
            reason: 'A loading indicator should be visible on the first frame.');
        expect(find.byType(ListView), findsNothing,
            reason: 'The list should not be visible while loading.');

        // ACT: Now that we've verified the loading state, we can let all
        // asynchronous processing complete. pumpAndSettle is the correct
        // tool for this part.
        await tester.pumpAndSettle(const Duration(seconds: 20));

        // ASSERT (Final State): The UI should now be settled with the list data.
        expect(find.byType(CircularProgressIndicator), findsNothing,
            reason: 'The loading indicator should be gone after data processing.');
        final listViewFinder = find.byType(ListView);
        expect(listViewFinder, findsOneWidget,
            reason: 'The ListView should be visible after data is loaded.');

        // ASSERT WITH PRECISION: Verify the content of the first card using its Key.
        final firstCardFinder = find.byKey(
          const ValueKey('daily_card_2025-07-01T00:00:00.000'),
        );
        expect(firstCardFinder, findsOneWidget);
        expect(
          find.descendant(
            of: firstCardFinder,
            matching: find.text('Tuesday, July 1, 2025'),
          ),
          findsOneWidget,
        );

        // ACT (Scrolling)
        final lastCardFinder = find.byKey(
          const ValueKey('daily_card_2025-12-31T00:00:00.000'),
        );
        await tester.scrollUntilVisible(
          lastCardFinder,
          500.0,
          scrollable: listViewFinder,
        );

        // ASSERT (After Scroll)
        expect(lastCardFinder, findsOneWidget,
            reason: 'The last item should be visible after scrolling to the end.');
      },
    );
  });
}