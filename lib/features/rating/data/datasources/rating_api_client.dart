import 'package:rural_ride/core/api/api_client.dart';

import '../models/rating_model.dart';

class RatingApiClient {
  final ApiClient apiClient;
  final String token;

  RatingApiClient({required this.apiClient, required this.token});

  Future<RatingModel> submitRating({
    required String rideId,
    required String ratedBy,
    required String ratedTo,
    required double score,
    required String comment,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/ratings',
      data: {
        'rideId': rideId,
        'ratedBy': ratedBy,
        'ratedTo': ratedTo,
        'score': score,
        'comment': comment,
      },
      token: token,
    );
    return RatingModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> getDriverRatings(String driverId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/drivers/$driverId/ratings',
      token: token,
    );
    return response.data ?? {};
  }

  Future<List<RatingModel>> getRatingHistory(String userId) async {
    final response = await apiClient.get<List<dynamic>>(
      '/users/$userId/ratings',
      token: token,
    );
    return (response.data ?? [])
        .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RatingModel?> getRideRating(String rideId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/rides/$rideId/rating',
      token: token,
    );
    if (response.data == null) return null;
    return RatingModel.fromJson(response.data!);
  }

  Future<void> deleteRating(String ratingId) async {
    await apiClient.delete<void>(
      '/ratings/$ratingId',
      token: token,
    );
  }
}
