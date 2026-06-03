import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class ProcessPaymentUsecase {
  final PaymentRepository repository;

  ProcessPaymentUsecase(this.repository);

  Future<Either<Failure, PaymentEntity>> call({
    required String rideId,
    required double amount,
    required String method,
  }) =>
      repository.processPayment(rideId: rideId, amount: amount, method: method);
}

class GetWalletUsecase {
  final PaymentRepository repository;

  GetWalletUsecase(this.repository);

  Future<Either<Failure, WalletEntity>> call(String userId) =>
      repository.getWalletBalance(userId);
}

class AddFundsUsecase {
  final PaymentRepository repository;

  AddFundsUsecase(this.repository);

  Future<Either<Failure, WalletEntity>> call({
    required String userId,
    required double amount,
    required String method,
  }) =>
      repository.addFunds(userId: userId, amount: amount, method: method);
}

class GetTransactionHistoryUsecase {
  final PaymentRepository repository;

  GetTransactionHistoryUsecase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call(String userId) =>
      repository.getTransactionHistory(userId);
}
