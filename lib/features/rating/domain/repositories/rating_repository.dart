import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/rating_entity.dart';

abstract class RatingRepository {
  Future<Either<Failure, RatingEntity>> submitRating({
    required String rideId,
    required String ratedBy,
    required String ratedTo,
    required int score,
    required String? comment,
  });

  Future<Either<Failure, List<RatingEntity>>> getRatings(String userId);

  Future<Either<Failure, double>> getAverageRating(String userId);

  Future<Either<Failure, List<RatingEntity>>> getReviews(String userId);
}
