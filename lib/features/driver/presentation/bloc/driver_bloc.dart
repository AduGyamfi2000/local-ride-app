// lib/features/driver/presentation/bloc/driver_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/voice_service.dart';
import '../../domain/usecases/update_driver_status_usecase.dart';
import '../../domain/usecases/accept_ride_usecase.dart';
import '../../../ride/domain/entities/ride_entity.dart';

// Events
abstract class DriverEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleOnlineEvent extends DriverEvent {
  final String driverId;
  final bool goOnline;
  ToggleOnlineEvent(this.driverId, this.goOnline);
}

class AcceptRideRequestEvent extends DriverEvent {
  final String driverId;
  final String rideId;
  AcceptRideRequestEvent(this.driverId, this.rideId);
}

class RejectRideRequestEvent extends DriverEvent {
  final String rideId;
  RejectRideRequestEvent(this.rideId);
}

class StartTripEvent extends DriverEvent {
  final String rideId;
  StartTripEvent(this.rideId);
}

class EndTripEvent extends DriverEvent {
  final String rideId;
  final double fare;
  EndTripEvent(this.rideId, this.fare);
}

class IncomingRideRequestEvent extends DriverEvent {
  final RideEntity ride;
  IncomingRideRequestEvent(this.ride);
}

// States
abstract class DriverState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {}
class DriverLoading extends DriverState {}

class DriverOnlineState extends DriverState {
  final double todayEarnings;
  final int tripsToday;
  DriverOnlineState({this.todayEarnings = 0, this.tripsToday = 0});
}

class DriverOfflineState extends DriverState {}

class IncomingRideState extends DriverState {
  final RideEntity ride;
  IncomingRideState(this.ride);
  @override
  List<Object?> get props => [ride];
}

class RideAcceptedState extends DriverState {
  final RideEntity ride;
  RideAcceptedState(this.ride);
}

class TripInProgressState extends DriverState {
  final RideEntity ride;
  TripInProgressState(this.ride);
}

class TripCompletedState extends DriverState {
  final double fare;
  final double totalToday;
  TripCompletedState(this.fare, this.totalToday);
}

class DriverErrorState extends DriverState {
  final String message;
  DriverErrorState(this.message);
}

// BLoC
class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final UpdateDriverStatusUsecase updateStatus;
  final AcceptRideUsecase acceptRide;
  final VoiceService voiceService;

  double _todayEarnings = 0;
  int _tripsToday = 0;

  DriverBloc({
    required this.updateStatus,
    required this.acceptRide,
    required this.voiceService,
  }) : super(DriverOfflineState()) {
    on<ToggleOnlineEvent>(_onToggleOnline);
    on<AcceptRideRequestEvent>(_onAcceptRide);
    on<RejectRideRequestEvent>(_onRejectRide);
    on<StartTripEvent>(_onStartTrip);
    on<EndTripEvent>(_onEndTrip);
    on<IncomingRideRequestEvent>(_onIncomingRide);
  }

  Future<void> _onToggleOnline(
      ToggleOnlineEvent event, Emitter<DriverState> emit) async {
    emit(DriverLoading());
    await updateStatus(event.driverId, event.goOnline ? 'online' : 'offline');
    if (event.goOnline) {
      await voiceService.speak('You are now online. Waiting for ride requests.');
      emit(DriverOnlineState(
          todayEarnings: _todayEarnings, tripsToday: _tripsToday));
    } else {
      await voiceService.speak('You are now offline.');
      emit(DriverOfflineState());
    }
  }

  Future<void> _onAcceptRide(
      AcceptRideRequestEvent event, Emitter<DriverState> emit) async {
    await acceptRide(event.driverId, event.rideId);
    await voiceService.speak('Ride accepted. Navigate to pickup location.');
  }

  Future<void> _onRejectRide(
      RejectRideRequestEvent event, Emitter<DriverState> emit) async {
    emit(DriverOnlineState(
        todayEarnings: _todayEarnings, tripsToday: _tripsToday));
  }

  Future<void> _onStartTrip(
      StartTripEvent event, Emitter<DriverState> emit) async {
    await voiceService.speak('Trip started. Drive safely.');
  }

  Future<void> _onEndTrip(
      EndTripEvent event, Emitter<DriverState> emit) async {
    _todayEarnings += event.fare;
    _tripsToday++;
    await voiceService
        .speak('Trip completed. You earned GHS ${event.fare.toStringAsFixed(2)}.');
    emit(TripCompletedState(event.fare, _todayEarnings));
  }

  Future<void> _onIncomingRide(
      IncomingRideRequestEvent event, Emitter<DriverState> emit) async {
    await voiceService.speak(
        'New ride request! From ${event.ride.pickup.address} to ${event.ride.destination.address}.');
    emit(IncomingRideState(event.ride));
  }
}
