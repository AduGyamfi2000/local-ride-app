part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class ProcessPaymentEvent extends PaymentEvent {
  final String rideId;
  final double amount;
  final String method;

  const ProcessPaymentEvent({
    required this.rideId,
    required this.amount,
    required this.method,
  });

  @override
  List<Object?> get props => [rideId, amount, method];
}

class GetWalletEvent extends PaymentEvent {
  final String userId;

  const GetWalletEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddFundsEvent extends PaymentEvent {
  final String userId;
  final double amount;
  final String method;

  const AddFundsEvent({
    required this.userId,
    required this.amount,
    required this.method,
  });

  @override
  List<Object?> get props => [userId, amount, method];
}

class GetTransactionHistoryEvent extends PaymentEvent {
  final String userId;

  const GetTransactionHistoryEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
