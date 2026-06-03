import '../../domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  const RatingModel({
    required super.id,
    required super.rideId,
    required super.ratedBy,
    required super.ratedTo,
    required super.score,
    super.comment,
    required super.timestamp,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      ratedBy: json['ratedBy'] as String,
      ratedTo: json['ratedTo'] as String,
      score: json['score'] as int,
      comment: json['comment'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'ratedBy': ratedBy,
      'ratedTo': ratedTo,
      'score': score,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
