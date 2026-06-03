import 'package:rural_ride/core/api/api_client.dart';


class AuthApiClient {
  final ApiClient apiClient;

  AuthApiClient({required this.apiClient});

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/send-otp',
      data: {'phoneNumber': phoneNumber},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String otp,
    String role,
  ) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'role': role,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
    );
    return response.data ?? {};
  }

  Future<void> logout(String token) async {
    await apiClient.post<void>(
      '/auth/logout',
      token: token,
    );
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/auth/me',
      token: token,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String token,
    String? name,
    String? address,
  }) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      '/users/$userId/profile',
      data: {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
      },
      token: token,
    );
    return response.data ?? {};
  }
}
