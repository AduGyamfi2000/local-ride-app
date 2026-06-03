import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/usecases/rating_usecases.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final SubmitRatingUsecase submitRatingUsecase;
  final GetRatingsUsecase getRatingsUsecase;
  final GetAverageRatingUsecase getAverageRatingUsecase;
  final GetReviewsUsecase getReviewsUsecase;

  RatingBloc({
    required this.submitRatingUsecase,
    required this.getRatingsUsecase,
    required this.getAverageRatingUsecase,
    required this.getReviewsUsecase,
  }) : super(RatingInitial()) {
    on<SubmitRatingEvent>(_onSubmitRating);
    on<GetRatingsEvent>(_onGetRatings);
    on<GetAverageRatingEvent>(_onGetAverageRating);
    on<GetReviewsEvent>(_onGetReviews);
  }

  Future<void> _onSubmitRating(
    SubmitRatingEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    final result = await submitRatingUsecase(
      rideId: event.rideId,
      ratedBy: event.ratedBy,
      ratedTo: event.ratedTo,
      score: event.score,
      comment: event.comment,
    );
    result.fold(
      (failure) => emit(RatingFailure(message: 'Failed to submit rating')),
      (rating) => emit(RatingSubmitted(rating: rating)),
    );
  }

  Future<void> _onGetRatings(
    GetRatingsEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    final result = await getRatingsUsecase(event.userId);
    result.fold(
      (failure) => emit(RatingFailure(message: 'Failed to fetch ratings')),
      (ratings) => emit(RatingsLoaded(ratings: ratings)),
    );
  }

  Future<void> _onGetAverageRating(
    GetAverageRatingEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    final result = await getAverageRatingUsecase(event.userId);
    result.fold(
      (failure) => emit(RatingFailure(message: 'Failed to fetch average rating')),
      (average) => emit(AverageRatingLoaded(average: average)),
    );
  }

  Future<void> _onGetReviews(
    GetReviewsEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    final result = await getReviewsUsecase(event.userId);
    result.fold(
      (failure) => emit(RatingFailure(message: 'Failed to fetch reviews')),
      (reviews) => emit(ReviewsLoaded(reviews: reviews)),
    );
  }
}
