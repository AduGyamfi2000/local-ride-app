import 'package:dartz/dartz.dart';
import 'package:rural_ride/core/services/offline_sync_service.dart';
import 'package:rural_ride/core/utils/network_info.dart';
import 'package:rural_ride/features/ride/data/models/ride_model.dart';
import 'package:rural_ride/features/ride/domain/entities/ride_entity.dart';
import 'package:rural_ride/features/ride/domain/repositories/ride_repository.dart';
import '../../../../core/errors/failures.dart';


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
      await offlineSyncService.saveRideRequestOffline(model.toJson());
      await local.cacheRide(model);
      return Right(model.copyWith(isSyncedOffline: false));
    }

    try {
      final result = await remote.requestRide(model);
      await local.cacheRide(result);
      return Right(result);
    } catch (_) {
      await offlineSyncService.saveRideRequestOffline(model.toJson());
      await local.cacheRide(model);
      return Right(model.copyWith(isSyncedOffline: false));
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
      } catch (_) {}
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
