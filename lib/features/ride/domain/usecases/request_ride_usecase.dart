// lib/features/ride/domain/usecases/request_ride_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

class RequestRideUsecase {
  final RideRepository repository;
  const RequestRideUsecase({required this.repository});

  Future<Either<Failure, RideEntity>> call(RideEntity ride) {
    return repository.requestRide(ride);
  }
}

// lib/features/ride/domain/usecases/get_ride_history_usecase.dart

class GetRideHistoryUsecase {
  final RideRepository repository;
  const GetRideHistoryUsecase({required this.repository});

  Future<Either<Failure, List<RideEntity>>> call(String userId) {
    return repository.getRideHistory(userId);
  }
}

// lib/features/ride/domain/usecases/get_active_ride_usecase.dart

class GetActiveRideUsecase {
  final RideRepository repository;
  const GetActiveRideUsecase({required this.repository});

  Future<Either<Failure, RideEntity?>> call(String userId) {
    return repository.getActiveRide(userId);
  }
}

// lib/features/ride/data/repositories/ride_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../../core/utils/network_info.dart';
import '../../data/datasources/ride_local_datasource.dart';
import '../../data/datasources/ride_remote_datasource.dart';
import '../../data/models/ride_model.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  final RideLocalDatasource local;
  final RideRemoteDatasource remote;
  final NetworkInfo networkInfo;
  final OfflineSyncService offlineSyncService;

  const RideRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo,
    required this.offlineSyncService,
  });

  @override
  Future<Either<Failure, RideEntity>> requestRide(RideEntity ride) async {
    final model = _toModel(ride);
    final isOnline = await networkInfo.isConnected;

    if (!isOnline) {
      // Save offline
      await offlineSyncService.saveRideRequestOffline(model.toJson());
      await local.cacheRide(model);
      return Right(model.copyWith(isSyncedOffline: false) as RideEntity);
    }

    try {
      final result = await remote.requestRide(model);
      await local.cacheRide(result);
      return Right(result);
    } catch (_) {
      // Fallback to offline
      await offlineSyncService.saveRideRequestOffline(model.toJson());
      await local.cacheRide(model);
      return Right(model.copyWith(isSyncedOffline: false) as RideEntity);
    }
  }

  @override
  Future<Either<Failure, List<RideEntity>>> getRideHistory(String userId) async {
    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      try {
        final remote_ = await remote.getRideHistory(userId);
        await local.saveRideHistory(remote_);
        return Right(remote_);
      } catch (_) {
        // fallthrough to local
      }
    }
    final cached = await local.getRideHistory(userId);
    return Right(cached);
  }

  @override
  Future<Either<Failure, RideEntity?>> getActiveRide(String userId) async {
    final cached = await local.getCachedActiveRide(userId);
    return Right(cached);
  }

  @override
  Future<Either<Failure, RideEntity>> updateRideStatus(String rideId, String status) async {
    return const Left(ServerFailure('Direct status updates not supported. Use stream.'));
  }

  @override
  Future<Either<Failure, void>> cancelRide(String rideId) async {
    return const Right(null);
  }

  @override
  Stream<RideEntity> getRideStream(String rideId) {
    return remote.getRideStream(rideId);
  }

  RideModel _toModel(RideEntity e) => RideModel(
        id: e.id,
        userId: e.userId,
        driverId: e.driverId,
        driverName: e.driverName,
        driverPhone: e.driverPhone,
        driverVehicle: e.driverVehicle,
        vehicleType: e.vehicleType,
        pickup: e.pickup,
        destination: e.destination,
        passengers: e.passengers,
        status: e.status,
        estimatedPrice: e.estimatedPrice,
        actualPrice: e.actualPrice,
        distanceKm: e.distanceKm,
        driverProfilePic: e.driverProfilePic,
        requestedAt: e.requestedAt,
        acceptedAt: e.acceptedAt,
        completedAt: e.completedAt,
        isSyncedOffline: e.isSyncedOffline,
        driverLat: e.driverLat,
        driverLng: e.driverLng,
        rating: e.rating,
        notes: e.notes,
      );
}
