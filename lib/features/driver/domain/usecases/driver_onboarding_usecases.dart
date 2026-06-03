import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/driver_onboarding_entity.dart';
import '../repositories/driver_onboarding_repository.dart';

class SubmitOnboardingDocsUsecase {
  final DriverOnboardingRepository repository;

  SubmitOnboardingDocsUsecase(this.repository);

  Future<Either<Failure, Unit>> call(
    String driverId,
    DriverOnboardingData data,
  ) =>
      repository.submitDocuments(driverId, data);
}

class GetOnboardingStatusUsecase {
  final DriverOnboardingRepository repository;

  GetOnboardingStatusUsecase(this.repository);

  Future<Either<Failure, DriverOnboardingEntity>> call(String driverId) =>
      repository.getOnboardingStatus(driverId);
}

class AcceptRideUsecase {
  final DriverOnboardingRepository repository;

  AcceptRideUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String rideId) => repository.acceptRide(rideId);
}

class DeclineRideUsecase {
  final DriverOnboardingRepository repository;

  DeclineRideUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String rideId) => repository.declineRide(rideId);
}

class StartRideUsecase {
  final DriverOnboardingRepository repository;

  StartRideUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String rideId) => repository.startRide(rideId);
}

class CompleteRideUsecase {
  final DriverOnboardingRepository repository;

  CompleteRideUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String rideId) => repository.completeRide(rideId);
}
