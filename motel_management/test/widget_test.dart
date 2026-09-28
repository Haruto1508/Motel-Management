import 'package:flutter_test/flutter_test.dart';
import 'package:rental_management/features/auth/presentation/screens/login_screen.dart';

void main() {
  test('Smoke test: LoginScreen can be instantiated', () {
    const page = LoginScreen();
    expect(page, isNotNull);
  });
}
