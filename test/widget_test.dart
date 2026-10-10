import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:just_budget/ui/settings/firebase_account_section.dart';

void main() {
  test('signed-in users should show the account summary instead of the login form', () {
    final user = MockUser(
      uid: 'user-123',
      email: 'alex@example.com',
    );

    expect(FirebaseAccountSection.shouldShowAccountSummary(user), isTrue);
    expect(FirebaseAccountSection.shouldShowAccountSummary(null), isFalse);
  });

  test('logged-out users should keep the login form visible', () {
    expect(FirebaseAccountSection.shouldShowAccountSummary(null), isFalse);
  });
}
