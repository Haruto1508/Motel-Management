import 'package:equatable/equatable.dart';

/// Pure domain entity representing access and refresh tokens
class AuthTokensEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int? expiresIn;

  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, expiresIn];
}
