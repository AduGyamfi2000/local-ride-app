import 'package:rural_ride/core/api/api_client.dart';


class DriverApiClient {
  final ApiClient apiClient;
  final String token;

  DriverApiClient({required this.apiClient, required this.token});

  Future<Map<String, dynamic>> getNearbyDrivers(
    double lat,
    double lng, {
    double radiusKm = 10.0,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/drivers/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radiusKm,
      },
      token: token,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getDriverDetails(String driverId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/drivers/$driverId',
      token: token,
    );
    return response.data ?? {};
  }

  Future<void> updateDriverStatus(String driverId, String status) async {
    await apiClient.put<void>(
      '/drivers/$driverId/status',
      data: {'status': status},
      token: token,
    );
  }

  Future<void> updateDriverLocation(String driverId, double lat, double lng) async {
    await apiClient.put<void>(
      '/drivers/$driverId/location',
      data: {'latitude': lat, 'longitude': lng},
      token: token,
    );
  }

  Future<Map<String, dynamic>> assignRideToDriver(String rideId, String driverId) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/assignments',
      data: {'rideId': rideId, 'driverId': driverId},
      token: token,
    );
    return response.data ?? {};
  }

  Future<void> acceptRide(String driverId, String rideId) async {
    await apiClient.post<void>(
      '/drivers/$driverId/rides/$rideId/accept',
      token: token,
    );
  }

  Future<void> rejectRide(String driverId, String rideId) async {
    await apiClient.post<void>(
      '/drivers/$driverId/rides/$rideId/reject',
      token: token,
    );
  }

  Future<void> startRide(String driverId, String rideId) async {
    await apiClient.post<void>(
      '/drivers/$driverId/rides/$rideId/start',
      token: token,
    );
  }

  Future<void> completeRide(String driverId, String rideId) async {
    await apiClient.post<void>(
      '/drivers/$driverId/rides/$rideId/complete',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getEarnings(String driverId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/drivers/$driverId/earnings',
      token: token,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getDriverRatings(String driverId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/drivers/$driverId/ratings',
      token: token,
    );
    return response.data ?? {};
  }
}
