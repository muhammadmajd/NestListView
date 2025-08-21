
import 'package:flutter_test/flutter_test.dart';
// Important: We import the file containing the code we want to test.
import '../lib/main.dart';

void main() {
  // A 'group' helps organize related tests together.
  group('SessionRepository Unit Tests', () {

    // A 'test' defines a single, specific test case.
    test('fetch should return a non-empty list of Session objects', () async {
      // ARRANGE: Set up the conditions for the test.
      final repository = SessionRepository();

      // ACT: Execute the code being tested.
      final sessions = await repository.fetch();

      // ASSERT: Verify that the outcome is what we expect.
      // 1. Check if the result is of the correct type (List<Session>).
      expect(sessions, isA<List<Session>>());
      // 2. Check if the list is not empty.
      expect(sessions, isNotEmpty);
      // 3. Check if the first item in the list is a valid Session object.
      expect(sessions.first.customer, contains('Customer'));
    });

  });
}