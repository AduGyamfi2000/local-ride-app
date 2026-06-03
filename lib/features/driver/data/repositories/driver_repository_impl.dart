import 'package:dartz/dartz.dart';
import 'package:rural_ride/features/driver/domain/repositories/driver_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/network_info.dart';

import '../../data/datasources/driver_local_datasource.dart';
import '../../data/datasources/driver_remote_datasource.dart';

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
