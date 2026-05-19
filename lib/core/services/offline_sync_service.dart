// lib/core/services/offline_sync_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/network_info.dart';

class PendingRideRequest {
  final String id;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool synced;

  PendingRideRequest({
    required this.id,
    required this.data,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'synced': synced,
      };

  factory PendingRideRequest.fromJson(Map<String, dynamic> json) =>
      PendingRideRequest(
        id: json['id'],
        data: Map<String, dynamic>.from(json['data']),
        createdAt: DateTime.parse(json['createdAt']),
        synced: json['synced'] ?? false,
      );
}

class OfflineSyncService {
  final NetworkInfo _networkInfo;
  Timer? _syncTimer;

  final _syncController = StreamController<List<PendingRideRequest>>.broadcast();
  Stream<List<PendingRideRequest>> get pendingStream => _syncController.stream;

  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal() : _networkInfo = NetworkInfoImpl();

  void startAutoSync() {
    _syncTimer = Timer.periodic(
      const Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) => syncPending(),
    );
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
  }

  /// Save a ride request offline
  Future<void> saveRideRequestOffline(Map<String, dynamic> rideData) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getPendingRequests();

    final pending = PendingRideRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: rideData,
      createdAt: DateTime.now(),
    );

    existing.add(pending);
    final encoded = existing.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(AppConstants.keyPendingRides, encoded);

    _syncController.add(existing);
    debugPrint('Ride request saved offline: ${pending.id}');
  }

  /// Get all pending (unsynced) requests
  Future<List<PendingRideRequest>> getPendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.keyPendingRides) ?? [];
    return raw
        .map((s) => PendingRideRequest.fromJson(jsonDecode(s)))
        .where((r) => !r.synced)
        .toList();
  }

  /// Try to sync pending requests when online
  Future<void> syncPending() async {
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) return;

    final pending = await getPendingRequests();
    if (pending.isEmpty) return;

    debugPrint('Syncing ${pending.length} pending ride requests...');

    for (final request in pending) {
      try {
        // In production: call API to submit request
        // await apiService.submitRideRequest(request.data);
        await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
        request.synced = true;
        debugPrint('Synced: ${request.id}');
      } catch (e) {
        debugPrint('Failed to sync ${request.id}: $e');
      }
    }

    // Remove synced requests from storage
    await _removesynced();
    final remaining = await getPendingRequests();
    _syncController.add(remaining);
  }

  Future<void> _removesynced() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.keyPendingRides) ?? [];
    final updated = raw
        .map((s) => PendingRideRequest.fromJson(jsonDecode(s)))
        .where((r) => !r.synced)
        .map((r) => jsonEncode(r.toJson()))
        .toList();
    await prefs.setStringList(AppConstants.keyPendingRides, updated);
  }

  Future<int> getPendingCount() async {
    final pending = await getPendingRequests();
    return pending.length;
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncController.close();
  }
}
