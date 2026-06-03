import 'package:rural_ride/core/api/api_client.dart';

import '../models/ride_model.dart';

class RideApiClient {
  final ApiClient apiClient;
  final String token;

  RideApiClient({required this.apiClient, required this.token});

  Future<RideModel> requestRide(RideModel ride) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/rides',
      data: ride.toJson(),
      token: token,
    );
    return RideModel.fromJson(response.data!);
  }

  Future<RideModel> getRideDetails(String rideId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/rides/$rideId',
      token: token,
    );
    return RideModel.fromJson(response.data!);
  }

  Future<List<RideModel>> getRideHistory(String userId) async {
    final response = await apiClient.get<List<dynamic>>(
      '/users/$userId/rides',
      token: token,
    );
    return (response.data ?? [])
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RideModel?> getActiveRide(String userId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/users/$userId/active-ride',
      token: token,
    );
    if (response.data == null) return null;
    return RideModel.fromJson(response.data!);
  }

  Future<RideModel> updateRideStatus(String rideId, String status) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '/rides/$rideId/status',
      data: {'status': status},
      token: token,
    );
    return RideModel.fromJson(response.data!);
  }

  Future<void> cancelRide(String rideId) async {
    await apiClient.delete<void>(
      '/rides/$rideId',
      token: token,
    );
  }

  Future<RideModel> completeRide(String rideId, double finalFare) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '/rides/$rideId/complete',
      data: {'actualFare': finalFare},
      token: token,
    );
    return RideModel.fromJson(response.data!);
  }
}
