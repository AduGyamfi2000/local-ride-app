// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_with_phone_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  SendOtpEvent(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;
  final String role;
  VerifyOtpEvent({required this.phoneNumber, required this.otp, required this.role});
  @override
  List<Object?> get props => [phoneNumber, otp, role];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String phoneNumber;
  OtpSentState(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class AuthenticatedState extends AuthState {
  final UserEntity user;
  AuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithPhoneUsecase loginWithPhone;
  final VerifyOtpUsecase verifyOtp;
  final SharedPreferences sharedPrefs;

  AuthBloc({
    required this.loginWithPhone,
    required this.verifyOtp,
    required this.sharedPrefs,
  }) : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginWithPhone(event.phoneNumber);
    result.fold(
      (failure) => emit(AuthErrorState(failure.message)),
      (_) => emit(OtpSentState(event.phoneNumber)),
    );
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifyOtp(
      VerifyOtpParams(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
        role: event.role,
      ),
    );
    result.fold(
      (failure) => emit(AuthErrorState(failure.message)),
      (user) => emit(AuthenticatedState(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await sharedPrefs.remove(AppConstants.keyUserToken);
    await sharedPrefs.remove(AppConstants.keyUserId);
    await sharedPrefs.remove(AppConstants.keyUserRole);
    await sharedPrefs.remove('cached_user');
    emit(UnauthenticatedState());
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    final token = sharedPrefs.getString(AppConstants.keyUserToken);
    if (token != null) {
      final raw = sharedPrefs.getString('cached_user');
      if (raw != null) {
        // user is cached
        emit(AuthInitial()); // let splash handle navigation
      }
    }
    emit(UnauthenticatedState());
  }
}
