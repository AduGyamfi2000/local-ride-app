part of 'rating_bloc.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {
  const RatingInitial();
}

class RatingLoading extends RatingState {
  const RatingLoading();
}

class RatingSubmitted extends RatingState {
  final RatingEntity rating;

  const RatingSubmitted({required this.rating});

  @override
  List<Object?> get props => [rating];
}

class RatingsLoaded extends RatingState {
  final List<RatingEntity> ratings;

  const RatingsLoaded({required this.ratings});

  @override
  List<Object?> get props => [ratings];
}

class AverageRatingLoaded extends RatingState {
  final double average;

  const AverageRatingLoaded({required this.average});

  @override
  List<Object?> get props => [average];
}

class ReviewsLoaded extends RatingState {
  final List<RatingEntity> reviews;

  const ReviewsLoaded({required this.reviews});

  @override
  List<Object?> get props => [reviews];
}

class RatingFailure extends RatingState {
  final String message;

  const RatingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
