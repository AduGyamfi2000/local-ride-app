import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:rural_ride/features/ride/domain/entities/ride_entity.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/driver_assignment_entity.dart';
import '../../domain/repositories/driver_assignment_repository.dart';
import '../datasources/driver_assignment_remote_datasource.dart';

class DriverAssignmentRepositoryImpl implements DriverAssignmentRepository {
  final DriverAssignmentRemoteDatasource remoteDatasource;

  DriverAssignmentRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<DriverEntity>>> findNearbyDrivers(
    LocationPoint location,
    double radiusInKm,
  ) async {
    try {
      final drivers = await remoteDatasource.findNearbyDrivers(location, radiusInKm);
      return Right(drivers);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DriverAssignmentEntity>> assignDriver(
    String rideId,
    String driverId,
  ) async {
    try {
      final assignment = await remoteDatasource.assignDriver(rideId, driverId);
      return Right(assignment);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, LocationPoint>> getDriverLocationStream(String driverId) {
    return remoteDatasource.getDriverLocationStream(driverId).map<Either<Failure, LocationPoint>>(
      (location) => Right(location as LocationPoint),
      onError: (error, stackTrace) => Left(ServerFailure()),
    );
  }

  @override
  Future<Either<Failure, Unit>> updateDriverLocation(
    String driverId,
    LocationPoint location,
  ) async {
    try {
      await remoteDatasource.updateDriverLocation(driverId, location);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
