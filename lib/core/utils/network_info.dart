// lib/core/utils/network_info.dart

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // In production, inject InternetConnectionChecker
  @override
  Future<bool> get isConnected async {
    try {
      // Use connectivity_plus + internet_connection_checker in real impl
      // For now, returns true as a stub
      return true;
    } catch (_) {
      return false;
    }
  }
}
