import '../../domain/entities/driver_assignment_entity.dart';

class DriverAssignmentModel extends DriverAssignmentEntity {
  const DriverAssignmentModel({
    required super.assignmentId,
    required super.rideId,
    required super.driverId,
    required super.status,
    super.acceptedAt,
    required super.timestamp,
  });

  factory DriverAssignmentModel.fromJson(Map<String, dynamic> json) {
    return DriverAssignmentModel(
      assignmentId: json['assignmentId'] as String,
      rideId: json['rideId'] as String,
      driverId: json['driverId'] as String,
      status: json['status'] as String,
      acceptedAt:
          json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt'] as String) : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'rideId': rideId,
      'driverId': driverId,
      'status': status,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
