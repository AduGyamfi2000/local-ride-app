import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource remoteDatasource;

  PaymentRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, PaymentEntity>> processPayment({
    required String rideId,
    required double amount,
    required String method,
    required String userId,
  }) async {
    try {
      final payment = await remoteDatasource.processPayment(
        rideId: rideId,
        amount: amount,
        method: method,
        userId: userId,
      );
      return Right(payment);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance(String userId) async {
    try {
      final wallet = await remoteDatasource.getWalletBalance(userId);
      return Right(wallet);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> addFunds({
    required String userId,
    required double amount,
    required String method,
  }) async {
    try {
      final wallet =
          await remoteDatasource.addFunds(userId: userId, amount: amount, method: method);
      return Right(wallet);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory(String userId) async {
    try {
      final transactions = await remoteDatasource.getTransactionHistory(userId);
      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
