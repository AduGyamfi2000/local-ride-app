import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DriverLocalDatasource {
  Future<void> cacheDriver(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedDriver();
}

class DriverLocalDatasourceImpl implements DriverLocalDatasource {
  final SharedPreferences sharedPrefs;
  DriverLocalDatasourceImpl({required this.sharedPrefs});

  @override
  Future<void> cacheDriver(Map<String, dynamic> data) async {
    await sharedPrefs.setString('driver_data', jsonEncode(data));
  }

  @override
  Future<Map<String, dynamic>?> getCachedDriver() async {
    final raw = sharedPrefs.getString('driver_data');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
