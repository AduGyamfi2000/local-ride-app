// lib/features/auth/data/datasources/auth_local_datasource.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearSession();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences sharedPrefs;
  AuthLocalDatasourceImpl({required this.sharedPrefs});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPrefs.setString(AppConstants.keyUserId, user.id);
    await sharedPrefs.setString(AppConstants.keyUserPhone, user.phone);
    await sharedPrefs.setString(AppConstants.keyUserRole, user.role);
    await sharedPrefs.setString('cached_user', jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = sharedPrefs.getString('cached_user');
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  @override
  Future<void> saveToken(String token) async {
    await sharedPrefs.setString(AppConstants.keyUserToken, token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPrefs.getString(AppConstants.keyUserToken);
  }

  @override
  Future<void> clearSession() async {
    await sharedPrefs.remove(AppConstants.keyUserToken);
    await sharedPrefs.remove(AppConstants.keyUserId);
    await sharedPrefs.remove(AppConstants.keyUserRole);
    await sharedPrefs.remove('cached_user');
  }
}

// lib/features/auth/data/datasources/auth_remote_datasource.dart

import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<String> sendOtp(String phoneNumber);
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp, String role);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  // In production: inject Dio and use real Firebase or custom backend
  @override
  Future<String> sendOtp(String phoneNumber) async {
    // Simulate OTP send
    await Future.delayed(const Duration(seconds: 1));
    return 'otp_sent';
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(
      String phoneNumber, String otp, String role) async {
    // Simulate OTP verification (accept any 6-digit OTP for demo)
    await Future.delayed(const Duration(seconds: 1));
    if (otp.length != 6) throw Exception('Invalid OTP');

    return {
      'user': {
        'id': 'user_${phoneNumber.replaceAll('+', '')}',
        'phone': phoneNumber,
        'name': 'RuralRide User',
        'role': role,
        'profilePicUrl': null,
        'address': null,
        'isVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      'token': 'token_${DateTime.now().millisecondsSinceEpoch}',
    };
  }
}
