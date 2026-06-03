import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/rating_entity.dart';
import '../repositories/rating_repository.dart';

class SubmitRatingUsecase {
  final RatingRepository repository;

  SubmitRatingUsecase(this.repository);

  Future<Either<Failure, RatingEntity>> call({
    required String rideId,
    required String ratedBy,
    required String ratedTo,
    required int score,
    required String? comment,
  }) =>
      repository.submitRating(
        rideId: rideId,
        ratedBy: ratedBy,
        ratedTo: ratedTo,
        score: score,
        comment: comment,
      );
}

class GetRatingsUsecase {
  final RatingRepository repository;

  GetRatingsUsecase(this.repository);

  Future<Either<Failure, List<RatingEntity>>> call(String userId) =>
      repository.getRatings(userId);
}

class GetAverageRatingUsecase {
  final RatingRepository repository;

  GetAverageRatingUsecase(this.repository);

  Future<Either<Failure, double>> call(String userId) =>
      repository.getAverageRating(userId);
}

class GetReviewsUsecase {
  final RatingRepository repository;

  GetReviewsUsecase(this.repository);

  Future<Either<Failure, List<RatingEntity>>> call(String userId) =>
      repository.getReviews(userId);
}
