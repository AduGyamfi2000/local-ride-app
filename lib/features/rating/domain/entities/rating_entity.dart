import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String rideId;
  final String ratedBy;
  final String ratedTo;
  final int score;
  final String? comment;
  final DateTime timestamp;

  const RatingEntity({
    required this.id,
    required this.rideId,
    required this.ratedBy,
    required this.ratedTo,
    required this.score,
    this.comment,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, rideId, ratedBy, ratedTo, score, comment, timestamp];
}
