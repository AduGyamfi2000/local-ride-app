// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RuralRide';
  static const String appVersion = '1.0.0';

  // Supported Vehicle Types
  static const List<String> vehicleTypes = ['Taxi', 'Motorcycle', 'Tricycle'];

  // Ride Status
  static const String rideStatusSearching = 'searching';
  static const String rideStatusAccepted = 'accepted';
  static const String rideStatusOnTheWay = 'on_the_way';
  static const String rideStatusArrived = 'arrived';
  static const String rideStatusInProgress = 'in_progress';
  static const String rideStatusCompleted = 'completed';
  static const String rideStatusCancelled = 'cancelled';

  // Driver Status
  static const String driverOnline = 'online';
  static const String driverOffline = 'offline';
  static const String driverBusy = 'busy';

  // Local Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyUserPhone = 'user_phone';
  static const String keyPendingRides = 'pending_rides';
  static const String keyLanguage = 'language';
  static const String keyOnboardingDone = 'onboarding_done';

  // User Roles
  static const String roleUser = 'user';
  static const String roleDriver = 'driver';
  static const String roleAdmin = 'admin';

  // Hive Box Names
  static const String rideRequestBox = 'ride_requests';
  static const String userBox = 'user_data';
  static const String driverBox = 'driver_data';

  // API Endpoints (swap with real backend)
  static const String baseUrl = 'https://api.ruralride.com/v1';
  static const String wsUrl = 'wss://ws.ruralride.com';

  // Offline sync interval (seconds)
  static const int syncIntervalSeconds = 30;

  // Map defaults (Ghana center)
  static const double defaultLat = 7.9465;
  static const double defaultLng = -1.0232;
  static const double defaultZoom = 7.0;
  static const double cityZoom = 14.0;

  // Price per km per vehicle type (GHS)
  static const Map<String, double> pricePerKm = {
    'Taxi': 3.5,
    'Motorcycle': 2.0,
    'Tricycle': 2.5,
  };

  // Base fare per vehicle type (GHS)
  static const Map<String, double> baseFare = {
    'Taxi': 5.0,
    'Motorcycle': 2.0,
    'Tricycle': 3.0,
  };

  // Supported languages
  static const String langEnglish = 'en';
  static const String langTwi = 'tw';

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'tw', 'name': 'Twi', 'native': 'Twi'},
  ];

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
