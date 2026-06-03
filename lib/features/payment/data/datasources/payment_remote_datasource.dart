import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import 'payment_api_client.dart';

abstract class PaymentRemoteDatasource {
  Future<PaymentModel> processPayment({
    required String rideId,
    required double amount,
    required String method,
    required String userId,
  });

  Future<WalletModel> getWalletBalance(String userId);

  Future<WalletModel> addFunds({
    required String userId,
    required double amount,
    required String method,
  });

  Future<List<TransactionModel>> getTransactionHistory(String userId);
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final FirebaseFirestore firestore;
  final PaymentApiClient? apiClient;

  PaymentRemoteDatasourceImpl(this.firestore, {this.apiClient});

  @override
  Future<PaymentModel> processPayment({
    required String rideId,
    required double amount,
    required String method,
    required String userId,
  }) async {
    if (apiClient != null) {
      return apiClient!.processPayment(
        userId: userId,
        rideId: rideId,
        amount: amount,
        method: method,
      );
    }

    try {
      final paymentId = firestore.collection('payments').doc().id;
      final paymentData = {
        'id': paymentId,
        'rideId': rideId,
        'userId': userId,
        'amount': amount,
        'paymentMethod': method,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
        'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      };

      await firestore.collection('payments').doc(paymentId).set(paymentData);
      await firestore
          .collection('wallets')
          .doc(userId)
          .update({'balance': FieldValue.increment(-amount)});

      return PaymentModel.fromJson({
        ...paymentData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  @override
  Future<WalletModel> getWalletBalance(String userId) async {
    if (apiClient != null) {
      final data = await apiClient!.getWallet(userId);
      return WalletModel.fromJson(data);
    }

    try {
      final doc = await firestore.collection('wallets').doc(userId).get();

      if (!doc.exists) {
        await firestore.collection('wallets').doc(userId).set({
          'userId': userId,
          'balance': 0.0,
          'phoneNumber': '',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        return WalletModel(
          userId: userId,
          balance: 0.0,
          phoneNumber: '',
          lastUpdated: DateTime.now(),
        );
      }

      return WalletModel.fromJson({
        ...doc.data()!,
        'lastUpdated':
            (doc.data()!['lastUpdated'] as Timestamp?)?.toDate().toIso8601String() ??
                DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to get wallet balance: $e');
    }
  }

  @override
  Future<WalletModel> addFunds({
    required String userId,
    required double amount,
    required String method,
  }) async {
    if (apiClient != null) {
      final data = await apiClient!.addFunds(userId: userId, amount: amount, method: method);
      return WalletModel.fromJson(data);
    }

    try {
      await firestore
          .collection('wallets')
          .doc(userId)
          .update({'balance': FieldValue.increment(amount)});

      return getWalletBalance(userId);
    } catch (e) {
      throw Exception('Failed to add funds: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory(String userId) async {
    if (apiClient != null) {
      final data = await apiClient!.getTransactionHistory(userId);
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    }

    try {
      final querySnapshot =
          await firestore.collection('transactions').where('userId', isEqualTo: userId).get();

      return querySnapshot.docs.map((doc) => TransactionModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }
}

