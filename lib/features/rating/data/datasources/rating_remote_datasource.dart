import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';
import 'rating_api_client.dart';

abstract class RatingRemoteDatasource {
  Future<RatingModel> submitRating({
    required String rideId,
    required String ratedBy,
    required String ratedTo,
    required int score,
    required String? comment,
  });

  Future<List<RatingModel>> getRatings(String userId);

  Future<double> getAverageRating(String userId);

  Future<List<RatingModel>> getReviews(String userId);
}

class RatingRemoteDatasourceImpl implements RatingRemoteDatasource {
  final FirebaseFirestore firestore;
  final RatingApiClient? apiClient;

  RatingRemoteDatasourceImpl(this.firestore, {this.apiClient});

  @override
  Future<RatingModel> submitRating({
    required String rideId,
    required String ratedBy,
    required String ratedTo,
    required int score,
    required String? comment,
  }) async {
    if (apiClient != null) {
      return apiClient!.submitRating(
        rideId: rideId,
        ratedBy: ratedBy,
        ratedTo: ratedTo,
        score: score.toDouble(),
        comment: comment ?? '',
      );
    }

    try {
      final ratingId = firestore.collection('ratings').doc().id;
      final ratingData = {
        'id': ratingId,
        'rideId': rideId,
        'ratedBy': ratedBy,
        'ratedTo': ratedTo,
        'score': score,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore.collection('ratings').doc(ratingId).set(ratingData);
      await _updateDriverAverageRating(ratedTo);

      return RatingModel.fromJson({
        ...ratingData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  @override
  Future<List<RatingModel>> getRatings(String userId) async {
    if (apiClient != null) {
      return apiClient!.getRatingHistory(userId);
    }

    try {
      final snapshot = await firestore
          .collection('ratings')
          .where('ratedTo', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => RatingModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get ratings: $e');
    }
  }

  @override
  Future<double> getAverageRating(String userId) async {
    try {
      final snapshot = await firestore
          .collection('ratings')
          .where('ratedTo', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final scores =
          snapshot.docs.map((doc) => (doc['score'] as int).toDouble()).toList();
      final average = scores.reduce((a, b) => a + b) / scores.length;

      return average;
    } catch (e) {
      throw Exception('Failed to get average rating: $e');
    }
  }

  @override
  Future<List<RatingModel>> getReviews(String userId) async {
    try {
      final snapshot = await firestore
          .collection('ratings')
          .where('ratedTo', isEqualTo: userId)
          .where('comment', isNotEqualTo: null)
          .orderBy('comment')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => RatingModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get reviews: $e');
    }
  }

  Future<void> _updateDriverAverageRating(String driverId) async {
    try {
      final average = await getAverageRating(driverId);
      await firestore
          .collection('drivers')
          .doc(driverId)
          .update({'averageRating': average});
    } catch (e) {
      // Silent fail
    }
  }
}

