part of 'driver_assignment_bloc.dart';

abstract class DriverAssignmentEvent extends Equatable {
  const DriverAssignmentEvent();

  @override
  List<Object?> get props => [];
}

class FindNearbyDriversEvent extends DriverAssignmentEvent {
  final LocationPoint location;
  final double radiusInKm;

  const FindNearbyDriversEvent({
    required this.location,
    this.radiusInKm = 5.0,
  });

  @override
  List<Object?> get props => [location, radiusInKm];
}

class AssignDriverEvent extends DriverAssignmentEvent {
  final String rideId;
  final String driverId;

  const AssignDriverEvent({
    required this.rideId,
    required this.driverId,
  });

  @override
  List<Object?> get props => [rideId, driverId];
}

class TrackDriverLocationEvent extends DriverAssignmentEvent {
  final String driverId;

  const TrackDriverLocationEvent(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class UpdateDriverLocationEvent extends DriverAssignmentEvent {
  final String driverId;
  final LocationPoint location;

  const UpdateDriverLocationEvent({
    required this.driverId,
    required this.location,
  });

  @override
  List<Object?> get props => [driverId, location];
}
