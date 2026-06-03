part of 'rating_bloc.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object?> get props => [];
}

class SubmitRatingEvent extends RatingEvent {
  final String rideId;
  final String ratedBy;
  final String ratedTo;
  final int score;
  final String? comment;

  const SubmitRatingEvent({
    required this.rideId,
    required this.ratedBy,
    required this.ratedTo,
    required this.score,
    this.comment,
  });

  @override
  List<Object?> get props => [rideId, ratedBy, ratedTo, score, comment];
}

class GetRatingsEvent extends RatingEvent {
  final String userId;

  const GetRatingsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GetAverageRatingEvent extends RatingEvent {
  final String userId;

  const GetAverageRatingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GetReviewsEvent extends RatingEvent {
  final String userId;

  const GetReviewsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
