import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String rideId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime timestamp;
  final String? transactionId;

  const PaymentEntity({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    this.transactionId,
  });

  @override
  List<Object?> get props => [
        id,
        rideId,
        userId,
        amount,
        paymentMethod,
        status,
        timestamp,
        transactionId,
      ];
}

class WalletEntity extends Equatable {
  final String userId;
  final double balance;
  final String phoneNumber;
  final DateTime lastUpdated;

  const WalletEntity({
    required this.userId,
    required this.balance,
    required this.phoneNumber,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [userId, balance, phoneNumber, lastUpdated];
}

class TransactionEntity extends Equatable {
  final String id;
  final String paymentId;
  final String type;
  final double amount;
  final DateTime timestamp;

  const TransactionEntity({
    required this.id,
    required this.paymentId,
    required this.type,
    required this.amount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, paymentId, type, amount, timestamp];
}
