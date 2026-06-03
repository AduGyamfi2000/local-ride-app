import 'package:rural_ride/core/api/api_client.dart';

import '../models/payment_model.dart';

class PaymentApiClient {
  final ApiClient apiClient;
  final String token;

  PaymentApiClient({required this.apiClient, required this.token});

  Future<PaymentModel> processPayment({
    required String userId,
    required String rideId,
    required double amount,
    required String method,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/payments',
      data: {
        'userId': userId,
        'rideId': rideId,
        'amount': amount,
        'method': method,
      },
      token: token,
    );
    return PaymentModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> getWallet(String userId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/users/$userId/wallet',
      token: token,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> addFunds({
    required String userId,
    required double amount,
    required String method,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/users/$userId/wallet/add-funds',
      data: {
        'amount': amount,
        'method': method,
      },
      token: token,
    );
    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(String userId) async {
    final response = await apiClient.get<List<dynamic>>(
      '/users/$userId/transactions',
      token: token,
    );
    return (response.data ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<PaymentModel> getPaymentDetails(String paymentId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/payments/$paymentId',
      token: token,
    );
    return PaymentModel.fromJson(response.data!);
  }

  Future<void> refundPayment(String paymentId) async {
    await apiClient.post<void>(
      '/payments/$paymentId/refund',
      token: token,
    );
  }
}
