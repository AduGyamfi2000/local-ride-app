// lib/features/auth/domain/usecases/login_with_phone_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhoneUsecase {
  final AuthRepository repository;
  const LoginWithPhoneUsecase({required this.repository});

  Future<Either<Failure, String>> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}

// lib/features/auth/domain/usecases/verify_otp_usecase.dart

import '../entities/user_entity.dart';

class VerifyOtpParams {
  final String phoneNumber;
  final String otp;
  final String role;
  const VerifyOtpParams({
    required this.phoneNumber,
    required this.otp,
    required this.role,
  });
}

class VerifyOtpUsecase {
  final AuthRepository repository;
  const VerifyOtpUsecase({required this.repository});

  Future<Either<Failure, UserEntity>> call(VerifyOtpParams params) {
    return repository.verifyOtp(params.phoneNumber, params.otp, params.role);
  }
}
