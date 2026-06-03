import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class DriverRepository {
  Future<Either<Failure, void>> updateStatus(String driverId, String status);
  Future<Either<Failure, void>> acceptRide(String driverId, String rideId);
}
