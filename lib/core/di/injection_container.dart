import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/voice_service.dart';
import '../services/offline_sync_service.dart';
import '../utils/network_info.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_phone_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/ride/domain/repositories/ride_repository.dart';
import '../../features/ride/domain/usecases/request_ride_usecase.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';
import '../../features/ride/data/datasources/ride_local_datasource.dart';
import '../../features/ride/data/datasources/ride_remote_datasource.dart';
import '../../features/ride/data/repositories/ride_repository_impl.dart';
import '../../features/driver/presentation/bloc/driver_bloc.dart';
import '../../features/driver/data/datasources/driver_local_datasource.dart';
import '../../features/driver/data/datasources/driver_remote_datasource.dart';
import '../../features/driver/data/repositories/driver_repository_impl.dart';
import '../../features/driver/domain/repositories/driver_repository.dart';
import '../../features/driver/domain/usecases/driver_usecases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/payment/data/datasources/payment_remote_datasource.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/payment_usecases.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── External Services ───────────────────────────────────────────────
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<VoiceService>(() => VoiceService());
  sl.registerLazySingleton<OfflineSyncService>(() => OfflineSyncService());

  // ─── Auth Feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(sharedPrefs: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDatasource: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginWithPhoneUsecase(repository: sl()));
  sl.registerLazySingleton(() => VerifyOtpUsecase(repository: sl()));

  sl.registerFactory(() => AuthBloc(
        loginWithPhone: sl(),
        verifyOtp: sl(),
        sharedPrefs: sl(),
      ));

  // ─── Ride Feature ─────────────────────────────────────────────────────
  sl.registerLazySingleton<RideLocalDatasource>(
    () => RideLocalDatasourceImpl(),
  );
  sl.registerLazySingleton<RideRemoteDatasource>(
    () => RideRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(
      local: sl(),
      remote: sl(),
      networkInfo: sl(),
      offlineSyncService: sl(),
    ),
  );
  sl.registerLazySingleton(() => RequestRideUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetRideHistoryUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetActiveRideUsecase(repository: sl()));

  sl.registerFactory(() => RideBloc(
        requestRide: sl(),
        getRideHistory: sl(),
        getActiveRide: sl(),
        voiceService: sl(),
        locationService: sl(),
      ));

  // ─── Driver Feature ───────────────────────────────────────────────────
  sl.registerLazySingleton<DriverLocalDatasource>(
    () => DriverLocalDatasourceImpl(sharedPrefs: sl()),
  );
  sl.registerLazySingleton<DriverRemoteDatasource>(
    () => DriverRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(
      local: sl(),
      remote: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => UpdateDriverStatusUsecase(repository: sl()));
  sl.registerLazySingleton(() => AcceptRideUsecase(repository: sl()));

  sl.registerFactory(() => DriverBloc(
        updateStatus: sl(),
        acceptRide: sl(),
        voiceService: sl(),
      ));

  // ─── Payment Feature ──────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentRemoteDatasource>(
    () => PaymentRemoteDatasourceImpl(FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ProcessPaymentUsecase(sl()));
  sl.registerLazySingleton(() => GetWalletUsecase(sl()));
  sl.registerLazySingleton(() => AddFundsUsecase(sl()));
  sl.registerLazySingleton(() => GetTransactionHistoryUsecase(sl()));

  sl.registerFactory(() => PaymentBloc(
        processPaymentUsecase: sl(),
        getWalletUsecase: sl(),
        addFundsUsecase: sl(),
        getTransactionHistoryUsecase: sl(),
      ));
}
