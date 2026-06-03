import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rural_ride/features/ride/domain/entities/ride_entity.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/driver_assignment_entity.dart';
import '../../domain/usecases/driver_assignment_usecases.dart';

part 'driver_assignment_event.dart';
part 'driver_assignment_state.dart';

class DriverAssignmentBloc extends Bloc<DriverAssignmentEvent, DriverAssignmentState> {
  final FindNearbyDriversUsecase findNearbyDriversUsecase;
  final AssignDriverUsecase assignDriverUsecase;
  final TrackDriverUsecase trackDriverUsecase;
  final UpdateDriverLocationUsecase updateDriverLocationUsecase;

  DriverAssignmentBloc({
    required this.findNearbyDriversUsecase,
    required this.assignDriverUsecase,
    required this.trackDriverUsecase,
    required this.updateDriverLocationUsecase,
  }) : super(DriverAssignmentInitial()) {
    on<FindNearbyDriversEvent>(_onFindNearbyDrivers);
    on<AssignDriverEvent>(_onAssignDriver);
    on<TrackDriverLocationEvent>(_onTrackDriver);
    on<UpdateDriverLocationEvent>(_onUpdateDriverLocation);
  }

  Future<void> _onFindNearbyDrivers(
    FindNearbyDriversEvent event,
    Emitter<DriverAssignmentState> emit,
  ) async {
    emit(DriverAssignmentLoading());
    final result = await findNearbyDriversUsecase(event.location, event.radiusInKm);
    result.fold(
      (failure) => emit(DriverAssignmentFailure(message: 'Failed to find drivers')),
      (drivers) => emit(DriversFound(drivers: drivers)),
    );
  }

  Future<void> _onAssignDriver(
    AssignDriverEvent event,
    Emitter<DriverAssignmentState> emit,
  ) async {
    emit(DriverAssignmentLoading());
    final result = await assignDriverUsecase(event.rideId, event.driverId);
    result.fold(
      (failure) => emit(DriverAssignmentFailure(message: 'Failed to assign driver')),
      (assignment) => emit(DriverAssigned(assignment: assignment)),
    );
  }

  Future<void> _onTrackDriver(
    TrackDriverLocationEvent event,
    Emitter<DriverAssignmentState> emit,
  ) async {
    emit(DriverAssignmentLoading());
    await emit.forEach<dynamic>(
      trackDriverUsecase(event.driverId),
      onData: (result) {
        if (result is LocationPoint) {
          return LocationUpdated(location: result);
        }
        return DriverAssignmentFailure(message: 'Failed to track driver');
      },
      onError: (error, stackTrace) =>
          DriverAssignmentFailure(message: 'Tracking error'),
    );
  }

  Future<void> _onUpdateDriverLocation(
    UpdateDriverLocationEvent event,
    Emitter<DriverAssignmentState> emit,
  ) async {
    final result = await updateDriverLocationUsecase(event.driverId, event.location);
    result.fold(
      (failure) => emit(DriverAssignmentFailure(message: 'Failed to update location')),
      (_) => emit(LocationUpdated(location: event.location)),
    );
  }
}
