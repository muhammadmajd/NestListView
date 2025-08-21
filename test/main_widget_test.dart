// test/main_widget_test.dart


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

// 1. CREATE A MOCK REPOSITORY
// This class mimics the real repository but returns a fixed, predictable set of
// data instantly. It allows us to control the test environment perfectly.
class MockSessionRepository extends SessionRepository {
  @override
  Future<List<Session>> fetch() {
    // Return a Future that completes immediately with our test data.
    return Future.value([
      Session(DateTime(2025, 7, 1), 'Customer A', 100),
      Session(DateTime(2025, 7, 1), 'Customer B', 200),
      Session(DateTime(2025, 7, 2), 'Customer C', 300),
    ]);
  }
}

void main() {
  group('SessionListScreen Widget Tests', () {
    testWidgets(
      'should show a loading indicator initially, then display a populated list',
          (WidgetTester tester) async {
        // ARRANGE: Set up the widget with our new MOCK repository.
        final mockRepository = MockSessionRepository();
        await tester.pumpWidget(MyApp(repository: mockRepository));

        // ASSERT (Initial State): The initial state is the same. The loader
        // is visible because the first frame is built before the Future completes.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // ACT: Settle the widget tree. Because our mock's Future resolves
        // instantly, pumpAndSettle will reliably wait for all the incremental
        // processing to finish in the test environment.
        await tester.pumpAndSettle();

        // ASSERT (Final State): The loader is gone and the list is visible.
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(ListView), findsOneWidget);

        // ASSERT (Data Correctness): Now, the test can reliably find the text
        // because we are certain the data processing has completed.
        expect(find.text('Tuesday, July 1, 2025'), findsOneWidget);
        expect(find.text('Customer A'), findsOneWidget);
        expect(find.text('100'), findsOneWidget); // Amount for Customer A

        // We can even check for the second day's data from our mock.
        expect(find.text('Wednesday, July 2, 2025'), findsOneWidget);
        expect(find.text('Customer C'), findsOneWidget);
      },
    );
  });
}