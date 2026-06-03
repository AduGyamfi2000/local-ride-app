// lib/features/driver/domain/entities/driver_entity.dart

import 'package:equatable/equatable.dart';
import 'package:rural_ride/core/utils/network_info.dart';

class DriverEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String vehicleType;
  final String vehiclePlate;
  final String status; // online, offline, busy
  final double? currentLat;
  final double? currentLng;
  final double rating;
  final int totalTrips;
  final double totalEarnings;
  final double todayEarnings;

  const DriverEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalEarnings = 0.0,
    this.todayEarnings = 0.0,
  });

  DriverEntity copyWith({
    String? status,
    double? currentLat,
    double? currentLng,
    double? todayEarnings,
    int? totalTrips,
  }) =>
      DriverEntity(
        id: id, name: name, phone: phone,
        vehicleType: vehicleType, vehiclePlate: vehiclePlate,
        status: status ?? this.status,
        currentLat: currentLat ?? this.currentLat,
        currentLng: currentLng ?? this.currentLng,
        rating: rating, totalEarnings: totalEarnings,
        todayEarnings: todayEarnings ?? this.todayEarnings,
        totalTrips: totalTrips ?? this.totalTrips,
      );

  @override
  List<Object?> get props => [id, status];
}

// ─── Driver datasources ─────────────────────────────────────────────────────

// lib/features/driver/data/datasources/driver_local_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DriverLocalDatasource {
  Future<void> cacheDriver(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedDriver();
}

class DriverLocalDatasourceImpl implements DriverLocalDatasource {
  final SharedPreferences sharedPrefs;
  DriverLocalDatasourceImpl({required this.sharedPrefs});

  @override
  Future<void> cacheDriver(Map<String, dynamic> data) async {
    await sharedPrefs.setString('driver_data', jsonEncode(data));
  }

  @override
  Future<Map<String, dynamic>?> getCachedDriver() async {
    final raw = sharedPrefs.getString('driver_data');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

// lib/features/driver/data/datasources/driver_remote_datasource.dart

abstract class DriverRemoteDatasource {
  Future<void> updateStatus(String driverId, String status);
  Future<void> acceptRide(String driverId, String rideId);
  Future<void> updateLocation(String driverId, double lat, double lng);
}

class DriverRemoteDatasourceImpl implements DriverRemoteDatasource {
  @override
  Future<void> updateStatus(String driverId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> acceptRide(String driverId, String rideId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateLocation(String driverId, double lat, double lng) async {}
}

// ─── Repository ──────────────────────────────────────────────────────────────

// lib/features/driver/domain/repositories/driver_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/driver_entity.dart';

abstract class DriverRepository {
  Future<Either<Failure, void>> updateStatus(String driverId, String status);
  Future<Either<Failure, void>> acceptRide(String driverId, String rideId);
}

// lib/features/driver/data/repositories/driver_repository_impl.dart

class DriverRepositoryImpl implements DriverRepository {
  final DriverLocalDatasource local;
  final DriverRemoteDatasource remote;
  final NetworkInfo networkInfo;

  const DriverRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> updateStatus(
      String driverId, String status) async {
    try {
      await remote.updateStatus(driverId, status);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> acceptRide(
      String driverId, String rideId) async {
    try {
      await remote.acceptRide(driverId, rideId);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

// ─── Use cases ───────────────────────────────────────────────────────────────

// lib/features/driver/domain/usecases/update_driver_status_usecase.dart

class UpdateDriverStatusUsecase {
  final DriverRepository repository;
  const UpdateDriverStatusUsecase({required this.repository});

  Future<Either<Failure, void>> call(String driverId, String status) =>
      repository.updateStatus(driverId, status);
}

// lib/features/driver/domain/usecases/accept_ride_usecase.dart

class AcceptRideUsecase {
  final DriverRepository repository;
  const AcceptRideUsecase({required this.repository});

  Future<Either<Failure, void>> call(String driverId, String rideId) =>
      repository.acceptRide(driverId, rideId);
}
