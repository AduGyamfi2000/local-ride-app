import 'package:equatable/equatable.dart';

class DriverOnboardingEntity extends Equatable {
  final String driverId;
  final String status;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String vehicleRegistration;
  final String insurancePolicyNumber;
  final DateTime insuranceExpiry;
  final String backgroundCheckStatus;
  final DateTime? approvedAt;
  final DateTime createdAt;

  const DriverOnboardingEntity({
    required this.driverId,
    required this.status,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.vehicleRegistration,
    required this.insurancePolicyNumber,
    required this.insuranceExpiry,
    required this.backgroundCheckStatus,
    this.approvedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        driverId,
        status,
        licenseNumber,
        licenseExpiry,
        vehicleRegistration,
        insurancePolicyNumber,
        insuranceExpiry,
        backgroundCheckStatus,
        approvedAt,
        createdAt,
      ];
}
