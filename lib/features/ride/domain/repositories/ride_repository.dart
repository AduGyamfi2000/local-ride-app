// lib/features/ride/domain/repositories/ride_repository.dart

import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:rural_ride/features/ride/data/models/ride_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ride_entity.dart';

abstract class RideRepository {
  Future<Either<Failure, RideEntity>> requestRide(RideEntity ride);
  Future<Either<Failure, List<RideEntity>>> getRideHistory(String userId);
  Future<Either<Failure, RideEntity?>> getActiveRide(String userId);
  Future<Either<Failure, RideEntity>> updateRideStatus(
      String rideId, String status);
  Future<Either<Failure, void>> cancelRide(String rideId);
  Stream<RideEntity> getRideStream(String rideId);
}

// lib/features/ride/data/datasources/ride_local_datasource.dart




abstract class RideLocalDatasource {
  Future<void> cacheRide(RideModel ride);
  Future<RideModel?> getCachedActiveRide(String userId);
  Future<List<RideModel>> getRideHistory(String userId);
  Future<void> saveRideHistory(List<RideModel> rides);
}

class RideLocalDatasourceImpl implements RideLocalDatasource {
  final SharedPreferences sharedPrefs;
  RideLocalDatasourceImpl({required this.sharedPrefs});

  @override
  Future<void> cacheRide(RideModel ride) async {
    await sharedPrefs.setString('active_ride_${ride.userId}', jsonEncode(ride.toJson()));
    // Also add to history
    final history = await getRideHistory(ride.userId);
    history.removeWhere((r) => r.id == ride.id);
    history.insert(0, ride);
    await saveRideHistory(history);
  }

  @override
  Future<RideModel?> getCachedActiveRide(String userId) async {
    final raw = sharedPrefs.getString('active_ride_$userId');
    if (raw == null) return null;
    final ride = RideModel.fromJson(jsonDecode(raw));
    if (['completed', 'cancelled'].contains(ride.status)) return null;
    return ride;
  }

  @override
  Future<List<RideModel>> getRideHistory(String userId) async {
    final raw = sharedPrefs.getString('ride_history_$userId');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((r) => RideModel.fromJson(r)).toList();
  }

  @override
  Future<void> saveRideHistory(List<RideModel> rides) async {
    if (rides.isEmpty) return;
    final userId = rides.first.userId;
    await sharedPrefs.setString(
      'ride_history_$userId',
      jsonEncode(rides.take(50).map((r) => r.toJson()).toList()),
    );
  }
}


abstract class RideRemoteDatasource {
  Future<RideModel> requestRide(RideModel ride);
  Future<List<RideModel>> getRideHistory(String userId);
  Future<RideModel?> getActiveRide(String userId);
  Future<RideModel> updateRideStatus(String rideId, String status);
  Stream<RideModel> getRideStream(String rideId);
}

class RideRemoteDatasourceImpl implements RideRemoteDatasource {
  final _rideControllers = <String, StreamController<RideModel>>{};

  @override
  Future<RideModel> requestRide(RideModel ride) async {
    await Future.delayed(const Duration(seconds: 1));
    return ride;
  }

  @override
  Future<List<RideModel>> getRideHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return mock history
    return _generateMockHistory(userId);
  }

  @override
  Future<RideModel?> getActiveRide(String userId) async {
    return null; // No active ride initially
  }

  @override
  Future<RideModel> updateRideStatus(String rideId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    throw UnimplementedError('Use stream for status updates');
  }

  @override
  Stream<RideModel> getRideStream(String rideId) {
    if (!_rideControllers.containsKey(rideId)) {
      _rideControllers[rideId] = StreamController<RideModel>.broadcast();
      _simulateRideProgress(rideId);
    }
    return _rideControllers[rideId]!.stream;
  }

  void _simulateRideProgress(String rideId) async {
    // Simulate driver accepting after 3s, then progressing through statuses
    await Future.delayed(const Duration(seconds: 3));
    // This is just a stub — real implementation uses Firestore or WebSocket
  }

  List<RideModel> _generateMockHistory(String userId) {
    final now = DateTime.now();
    final statuses = ['completed', 'completed', 'cancelled', 'completed'];
    final vehicles = ['Taxi', 'Motorcycle', 'Tricycle', 'Taxi'];
    final pickups = ['Market Circle', 'Kejetia', 'Tamale Central', 'Kumasi Station'];
    final dests = ['Suame Magazine', 'Anloga Junction', 'Bulpela', 'KNUST'];
    final prices = [12.50, 6.00, 8.75, 18.00];

    return List.generate(
      4,
      (i) => RideModel(
        id: 'ride_hist_$i',
        userId: userId,
        driverName: 'Kwame Asante',
        driverPhone: '+233241234567',
        vehicleType: vehicles[i],
        pickup: LocationPointModel(lat: 6.6, lng: -1.6, address: pickups[i]),
        destination: LocationPointModel(lat: 6.7, lng: -1.5, address: dests[i]),
        passengers: 1 + i % 3,
        status: statuses[i],
        actualPrice: prices[i],
        distanceKm: 2.5 + i * 1.2,
        requestedAt: now.subtract(Duration(days: i * 2 + 1)),
        completedAt: statuses[i] == 'completed'
            ? now.subtract(Duration(days: i * 2))
            : null,
      ),
    );
  }
}
