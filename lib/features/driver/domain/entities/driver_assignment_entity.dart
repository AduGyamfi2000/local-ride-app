import 'package:equatable/equatable.dart';

class DriverAssignmentEntity extends Equatable {
  final String assignmentId;
  final String rideId;
  final String driverId;
  final String status;
  final DateTime? acceptedAt;
  final DateTime timestamp;

  const DriverAssignmentEntity({
    required this.assignmentId,
    required this.rideId,
    required this.driverId,
    required this.status,
    this.acceptedAt,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [assignmentId, rideId, driverId, status, acceptedAt, timestamp];
}
