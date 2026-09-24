import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rental_management/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:rental_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:rental_management/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginUseCase loginUseCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'landlord@rental.com';
  const tPassword = 'Password123!';
  const tTokens = AuthTokensEntity(
    accessToken: 'mock_access_token_123',
    refreshToken: 'mock_refresh_token_456',
  );

  test('LoginUseCase should call AuthRepository.login and return AuthTokensEntity', () async {
    // Arrange
    when(
      () => mockAuthRepository.login(
        email: tEmail,
        password: tPassword,
      ),
    ).thenAnswer((_) async => tTokens);

    // Act
    final result = await loginUseCase(
      const LoginParams(email: tEmail, password: tPassword),
    );

    // Assert
    expect(result, equals(tTokens));
    expect(result.accessToken, 'mock_access_token_123');
    verify(() => mockAuthRepository.login(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
