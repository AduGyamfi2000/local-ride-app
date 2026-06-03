import 'package:dartz/dartz.dart';
import 'package:rural_ride/features/ride/domain/entities/ride_entity.dart';
import '../../../../core/errors/failures.dart';
import '../entities/driver_entity.dart';
import '../entities/driver_assignment_entity.dart';


abstract class DriverAssignmentRepository {
  Future<Either<Failure, List<DriverEntity>>> findNearbyDrivers(
    LocationPoint location,
    double radiusInKm,
  );

  Future<Either<Failure, DriverAssignmentEntity>> assignDriver(
    String rideId,
    String driverId,
  );

  Stream<Either<Failure, LocationPoint>> getDriverLocationStream(String driverId);

  Future<Either<Failure, Unit>> updateDriverLocation(
    String driverId,
    LocationPoint location,
  );
}
