// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    required super.name,
    required super.role,
    super.profilePicUrl,
    super.address,
    super.isVerified,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        phone: json['phone'] ?? '',
        name: json['name'] ?? 'User',
        role: json['role'] ?? 'user',
        profilePicUrl: json['profilePicUrl'],
        address: json['address'],
        isVerified: json['isVerified'] ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'role': role,
        'profilePicUrl': profilePicUrl,
        'address': address,
        'isVerified': isVerified,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        phone: entity.phone,
        name: entity.name,
        role: entity.role,
        profilePicUrl: entity.profilePicUrl,
        address: entity.address,
        isVerified: entity.isVerified,
        createdAt: entity.createdAt,
      );
}
