// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, UserEntity>> verifyOtp(String phoneNumber, String otp, String role);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? address,
    String? profilePicPath,
  });
}
