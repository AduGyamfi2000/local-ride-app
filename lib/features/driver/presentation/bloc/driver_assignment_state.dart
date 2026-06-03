part of 'driver_assignment_bloc.dart';

abstract class DriverAssignmentState extends Equatable {
  const DriverAssignmentState();

  @override
  List<Object?> get props => [];
}

class DriverAssignmentInitial extends DriverAssignmentState {
  const DriverAssignmentInitial();
}

class DriverAssignmentLoading extends DriverAssignmentState {
  const DriverAssignmentLoading();
}

class DriversFound extends DriverAssignmentState {
  final List<DriverEntity> drivers;

  const DriversFound({required this.drivers});

  @override
  List<Object?> get props => [drivers];
}

class DriverAssigned extends DriverAssignmentState {
  final DriverAssignmentEntity assignment;

  const DriverAssigned({required this.assignment});

  @override
  List<Object?> get props => [assignment];
}

class LocationUpdated extends DriverAssignmentState {
  final LocationPoint location;

  const LocationUpdated({required this.location});

  @override
  List<Object?> get props => [location];
}

class DriverAssignmentFailure extends DriverAssignmentState {
  final String message;

  const DriverAssignmentFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
