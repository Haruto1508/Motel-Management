import 'package:flutter_test/flutter_test.dart';
import 'package:rental_management/features/auth/presentation/pages/login_page.dart';

void main() {
  test('Smoke test: LoginPage can be instantiated', () {
    const page = LoginPage();
    expect(page, isNotNull);
  });
}
