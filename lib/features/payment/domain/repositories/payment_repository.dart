import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentEntity>> processPayment({
    required String rideId,
    required double amount,
    required String method,
  });

  Future<Either<Failure, WalletEntity>> getWalletBalance(String userId);

  Future<Either<Failure, WalletEntity>> addFunds({
    required String userId,
    required double amount,
    required String method,
  });

  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory(
    String userId,
  );
}
