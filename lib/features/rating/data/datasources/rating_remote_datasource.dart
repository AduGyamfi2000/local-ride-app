import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';

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

  RatingRemoteDatasourceImpl(this.firestore);

  @override
  Future<RatingModel> submitRating({
    required String rideId,
    required String ratedBy,
    required String ratedTo,
    required int score,
    required String? comment,
  }) async {
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

      // Update driver's average rating
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
      // Silent fail - rating submission succeeded even if update fails
    }
  }
}
