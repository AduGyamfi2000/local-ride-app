// lib/features/ride/presentation/bloc/ride_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/voice_service.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/usecases/request_ride_usecase.dart';
import '../../domain/usecases/get_ride_history_usecase.dart';
import '../../domain/usecases/get_active_ride_usecase.dart';

// Events
abstract class RideEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RequestRideEvent extends RideEvent {
  final RideEntity ride;
  RequestRideEvent(this.ride);
  @override
  List<Object?> get props => [ride];
}

class LoadRideHistoryEvent extends RideEvent {
  final String userId;
  LoadRideHistoryEvent(this.userId);
}

class LoadActiveRideEvent extends RideEvent {
  final String userId;
  LoadActiveRideEvent(this.userId);
}

class RideStatusChangedEvent extends RideEvent {
  final RideEntity ride;
  RideStatusChangedEvent(this.ride);
}

class CancelRideEvent extends RideEvent {
  final String rideId;
  CancelRideEvent(this.rideId);
}

// States
abstract class RideState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RideInitial extends RideState {}
class RideLoading extends RideState {}

class RideRequestedState extends RideState {
  final RideEntity ride;
  final bool isOffline;
  RideRequestedState(this.ride, {this.isOffline = false});
  @override
  List<Object?> get props => [ride, isOffline];
}

class RideActiveState extends RideState {
  final RideEntity ride;
  RideActiveState(this.ride);
  @override
  List<Object?> get props => [ride];
}

class RideHistoryLoadedState extends RideState {
  final List<RideEntity> rides;
  RideHistoryLoadedState(this.rides);
  @override
  List<Object?> get props => [rides];
}

class RideCompletedState extends RideState {
  final RideEntity ride;
  RideCompletedState(this.ride);
}

class RideErrorState extends RideState {
  final String message;
  RideErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

class NoActiveRideState extends RideState {}

// BLoC
class RideBloc extends Bloc<RideEvent, RideState> {
  final RequestRideUsecase requestRide;
  final GetRideHistoryUsecase getRideHistory;
  final GetActiveRideUsecase getActiveRide;
  final VoiceService voiceService;
  final LocationService locationService;

  StreamSubscription? _rideStreamSub;

  RideBloc({
    required this.requestRide,
    required this.getRideHistory,
    required this.getActiveRide,
    required this.voiceService,
    required this.locationService,
  }) : super(RideInitial()) {
    on<RequestRideEvent>(_onRequestRide);
    on<LoadRideHistoryEvent>(_onLoadHistory);
    on<LoadActiveRideEvent>(_onLoadActive);
    on<RideStatusChangedEvent>(_onStatusChanged);
    on<CancelRideEvent>(_onCancel);
  }

  Future<void> _onRequestRide(
      RequestRideEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    final result = await requestRide(event.ride);
    result.fold(
      (failure) => emit(RideErrorState(failure.message)),
      (ride) {
        final offline = !ride.isSyncedOffline;
        emit(RideRequestedState(ride, isOffline: offline));
        if (offline) {
          voiceService.speak(
              'No internet. Your ride request has been saved and will be sent when you are online.');
        } else {
          voiceService.announceRideStatus(ride.status);
        }
      },
    );
  }

  Future<void> _onLoadHistory(
      LoadRideHistoryEvent event, Emitter<RideState> emit) async {
    emit(RideLoading());
    final result = await getRideHistory(event.userId);
    result.fold(
      (failure) => emit(RideErrorState(failure.message)),
      (rides) => emit(RideHistoryLoadedState(rides)),
    );
  }

  Future<void> _onLoadActive(
      LoadActiveRideEvent event, Emitter<RideState> emit) async {
    final result = await getActiveRide(event.userId);
    result.fold(
      (failure) => emit(NoActiveRideState()),
      (ride) {
        if (ride == null) {
          emit(NoActiveRideState());
        } else {
          emit(RideActiveState(ride));
        }
      },
    );
  }

  Future<void> _onStatusChanged(
      RideStatusChangedEvent event, Emitter<RideState> emit) async {
    final ride = event.ride;
    if (ride.status == 'completed') {
      emit(RideCompletedState(ride));
      voiceService.announceRideStatus(ride.status);
    } else {
      emit(RideActiveState(ride));
      voiceService.announceRideStatus(ride.status);
    }
  }

  Future<void> _onCancel(CancelRideEvent event, Emitter<RideState> emit) async {
    emit(NoActiveRideState());
  }

  @override
  Future<void> close() {
    _rideStreamSub?.cancel();
    return super.close();
  }
}
