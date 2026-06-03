import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/payment_usecases.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final ProcessPaymentUsecase processPaymentUsecase;
  final GetWalletUsecase getWalletUsecase;
  final AddFundsUsecase addFundsUsecase;
  final GetTransactionHistoryUsecase getTransactionHistoryUsecase;

  PaymentBloc({
    required this.processPaymentUsecase,
    required this.getWalletUsecase,
    required this.addFundsUsecase,
    required this.getTransactionHistoryUsecase,
  }) : super(PaymentInitial()) {
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<GetWalletEvent>(_onGetWallet);
    on<AddFundsEvent>(_onAddFunds);
    on<GetTransactionHistoryEvent>(_onGetTransactionHistory);
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await processPaymentUsecase(
      rideId: event.rideId,
      amount: event.amount,
      method: event.method,
    );
    result.fold(
      (failure) => emit(PaymentFailure(message: 'Payment failed')),
      (payment) => emit(PaymentSuccess(payment: payment)),
    );
  }

  Future<void> _onGetWallet(
    GetWalletEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await getWalletUsecase(event.userId);
    result.fold(
      (failure) => emit(PaymentFailure(message: 'Failed to fetch wallet')),
      (wallet) => emit(WalletLoaded(wallet: wallet)),
    );
  }

  Future<void> _onAddFunds(
    AddFundsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await addFundsUsecase(
      userId: event.userId,
      amount: event.amount,
      method: event.method,
    );
    result.fold(
      (failure) => emit(PaymentFailure(message: 'Failed to add funds')),
      (wallet) => emit(WalletLoaded(wallet: wallet)),
    );
  }

  Future<void> _onGetTransactionHistory(
    GetTransactionHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await getTransactionHistoryUsecase(event.userId);
    result.fold(
      (failure) => emit(PaymentFailure(message: 'Failed to fetch transactions')),
      (transactions) => emit(TransactionHistoryLoaded(transactions: transactions)),
    );
  }
}
