// lib/features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String role; // user, driver, admin
  final String? profilePicUrl;
  final String? address;
  final bool isVerified;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.profilePicUrl,
    this.address,
    this.isVerified = false,
    this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? phone,
    String? name,
    String? role,
    String? profilePicUrl,
    String? address,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      address: address ?? this.address,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, phone, name, role, profilePicUrl, address, isVerified];
}
