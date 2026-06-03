part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

class PaymentSuccess extends PaymentState {
  final PaymentEntity payment;

  const PaymentSuccess({required this.payment});

  @override
  List<Object?> get props => [payment];
}

class PaymentFailure extends PaymentState {
  final String message;

  const PaymentFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class WalletLoaded extends PaymentState {
  final WalletEntity wallet;

  const WalletLoaded({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

class TransactionHistoryLoaded extends PaymentState {
  final List<TransactionEntity> transactions;

  const TransactionHistoryLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}
