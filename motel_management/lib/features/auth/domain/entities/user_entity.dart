import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated user (Landlord/Admin/Staff)
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, phone, role, avatarUrl];
}
