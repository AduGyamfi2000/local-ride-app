import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_remote_datasource.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDatasource remoteDatasource;

  RatingRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, RatingEntity>> submitRating({
    required String rideId,
    required String ratedBy,
    required String ratedTo,
    required int score,
    required String? comment,
  }) async {
    try {
      final rating = await remoteDatasource.submitRating(
        rideId: rideId,
        ratedBy: ratedBy,
        ratedTo: ratedTo,
        score: score,
        comment: comment,
      );
      return Right(rating);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<RatingEntity>>> getRatings(String userId) async {
    try {
      final ratings = await remoteDatasource.getRatings(userId);
      return Right(ratings);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, double>> getAverageRating(String userId) async {
    try {
      final average = await remoteDatasource.getAverageRating(userId);
      return Right(average);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<RatingEntity>>> getReviews(String userId) async {
    try {
      final reviews = await remoteDatasource.getReviews(userId);
      return Right(reviews);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
