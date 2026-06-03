import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/driver_repository.dart';

class UpdateDriverStatusUsecase {
  final DriverRepository repository;
  const UpdateDriverStatusUsecase({required this.repository});

  Future<Either<Failure, void>> call(String driverId, String status) =>
      repository.updateStatus(driverId, status);
}

class AcceptRideUsecase {
  final DriverRepository repository;
  const AcceptRideUsecase({required this.repository});

  Future<Either<Failure, void>> call(String driverId, String rideId) =>
      repository.acceptRide(driverId, rideId);
}
