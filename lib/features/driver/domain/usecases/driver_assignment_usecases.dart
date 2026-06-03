import 'package:dartz/dartz.dart';
import 'package:rural_ride/features/ride/domain/entities/ride_entity.dart';
import '../../../../core/errors/failures.dart';

import '../entities/driver_entity.dart';
import '../entities/driver_assignment_entity.dart';
import '../repositories/driver_assignment_repository.dart';

class FindNearbyDriversUsecase {
  final DriverAssignmentRepository repository;

  FindNearbyDriversUsecase(this.repository);

  Future<Either<Failure, List<DriverEntity>>> call(
    LocationPoint location,
    double radiusInKm,
  ) =>
      repository.findNearbyDrivers(location, radiusInKm);
}

class AssignDriverUsecase {
  final DriverAssignmentRepository repository;

  AssignDriverUsecase(this.repository);

  Future<Either<Failure, DriverAssignmentEntity>> call(
    String rideId,
    String driverId,
  ) =>
      repository.assignDriver(rideId, driverId);
}

class TrackDriverUsecase {
  final DriverAssignmentRepository repository;

  TrackDriverUsecase(this.repository);

  Stream<Either<Failure, LocationPoint>> call(String driverId) =>
      repository.getDriverLocationStream(driverId);
}

class UpdateDriverLocationUsecase {
  final DriverAssignmentRepository repository;

  UpdateDriverLocationUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String driverId, LocationPoint location) =>
      repository.updateDriverLocation(driverId, location);
}
