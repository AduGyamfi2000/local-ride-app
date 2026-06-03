// lib/features/ride/domain/usecases/request_ride_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

class RequestRideUsecase {
  final RideRepository repository;
  const RequestRideUsecase({required this.repository});

  Future<Either<Failure, RideEntity>> call(RideEntity ride) {
    return repository.requestRide(ride);
  }
}

class GetRideHistoryUsecase {
  final RideRepository repository;
  const GetRideHistoryUsecase({required this.repository});

  Future<Either<Failure, List<RideEntity>>> call(String userId) {
    return repository.getRideHistory(userId);
  }
}

class GetActiveRideUsecase {
  final RideRepository repository;
  const GetActiveRideUsecase({required this.repository});

  Future<Either<Failure, RideEntity?>> call(String userId) {
    return repository.getActiveRide(userId);
  }
}
