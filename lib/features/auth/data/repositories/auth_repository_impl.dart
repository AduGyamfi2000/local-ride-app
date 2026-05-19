// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;
  final AuthRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    final isOnline = await networkInfo.isConnected;
    if (!isOnline) return const Left(NetworkFailure());
    try {
      final result = await remoteDatasource.sendOtp(phoneNumber);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(
      String phoneNumber, String otp, String role) async {
    final isOnline = await networkInfo.isConnected;
    if (!isOnline) return const Left(NetworkFailure());
    try {
      final data = await remoteDatasource.verifyOtp(phoneNumber, otp, role);
      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;
      await localDatasource.cacheUser(user);
      await localDatasource.saveToken(token);
      return Right(user);
    } catch (e) {
      if (e.toString().contains('Invalid')) {
        return const Left(AuthFailure('Wrong OTP. Please try again.'));
      }
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDatasource.getCachedUser();
      return Right(user);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDatasource.clearSession();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? name,
    String? address,
    String? profilePicPath,
  }) async {
    try {
      final current = await localDatasource.getCachedUser();
      if (current == null) return const Left(AuthFailure());
      final updated = UserModel(
        id: current.id,
        phone: current.phone,
        name: name ?? current.name,
        role: current.role,
        profilePicUrl: profilePicPath ?? current.profilePicUrl,
        address: address ?? current.address,
        isVerified: current.isVerified,
        createdAt: current.createdAt,
      );
      await localDatasource.cacheUser(updated);
      return Right(updated);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
