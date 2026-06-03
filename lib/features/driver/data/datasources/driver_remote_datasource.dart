import 'driver_api_client.dart';

abstract class DriverRemoteDatasource {
  Future<void> updateStatus(String driverId, String status);
  Future<void> acceptRide(String driverId, String rideId);
  Future<void> updateLocation(String driverId, double lat, double lng);
}

class DriverRemoteDatasourceImpl implements DriverRemoteDatasource {
  final DriverApiClient apiClient;

  DriverRemoteDatasourceImpl({DriverApiClient? apiClient})
      : apiClient = apiClient ?? DriverApiClient(
          apiClient: throw Exception('ApiClient required'),
          token: '',
        );

  @override
  Future<void> updateStatus(String driverId, String status) async {
    return apiClient.updateDriverStatus(driverId, status);
  }

  @override
  Future<void> acceptRide(String driverId, String rideId) async {
    return apiClient.acceptRide(driverId, rideId);
  }

  @override
  Future<void> updateLocation(String driverId, double lat, double lng) async {
    return apiClient.updateDriverLocation(driverId, lat, lng);
  }
}


