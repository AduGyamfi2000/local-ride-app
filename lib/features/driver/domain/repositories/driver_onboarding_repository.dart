import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/driver_onboarding_entity.dart';

class DriverOnboardingData {
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String vehicleRegistration;
  final String insurancePolicyNumber;
  final DateTime insuranceExpiry;
  final String? licensePhotoPath;
  final String? insurancePhotoPath;

  DriverOnboardingData({
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.vehicleRegistration,
    required this.insurancePolicyNumber,
    required this.insuranceExpiry,
    this.licensePhotoPath,
    this.insurancePhotoPath,
  });
}

abstract class DriverOnboardingRepository {
  Future<Either<Failure, Unit>> submitDocuments(
    String driverId,
    DriverOnboardingData data,
  );

  Future<Either<Failure, DriverOnboardingEntity>> getOnboardingStatus(String driverId);

  Future<Either<Failure, Unit>> acceptRide(String rideId);

  Future<Either<Failure, Unit>> declineRide(String rideId);

  Future<Either<Failure, Unit>> startRide(String rideId);

  Future<Either<Failure, Unit>> completeRide(String rideId);
}
