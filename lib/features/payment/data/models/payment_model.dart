import '../../../payment/domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.rideId,
    required super.userId,
    required super.amount,
    required super.paymentMethod,
    required super.status,
    required super.timestamp,
    super.transactionId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'transactionId': transactionId,
    };
  }
}

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.userId,
    required super.balance,
    required super.phoneNumber,
    required super.lastUpdated,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'phoneNumber': phoneNumber,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.paymentId,
    required super.type,
    required super.amount,
    required super.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentId': paymentId,
      'type': type,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
