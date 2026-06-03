import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rural_ride/features/ride/domain/entities/ride_entity.dart';

import '../models/driver_assignment_model.dart';


abstract class DriverAssignmentRemoteDatasource {
  Future<List<DriverModel>> findNearbyDrivers(
    LocationPoint location,
    double radiusInKm,
  );

  Future<DriverAssignmentModel> assignDriver(String rideId, String driverId);

  Stream<LocationPoint> getDriverLocationStream(String driverId);

  Future<void> updateDriverLocation(String driverId, LocationPoint location);
}

class DriverAssignmentRemoteDatasourceImpl implements DriverAssignmentRemoteDatasource {
  final FirebaseFirestore firestore;

  DriverAssignmentRemoteDatasourceImpl(this.firestore);

  @override
  Future<List<DriverModel>> findNearbyDrivers(
    LocationPoint location,
    double radiusInKm,
  ) async {
    try {
      final query = firestore
          .collection('drivers')
          .where('status', isEqualTo: 'online')
          .limit(10);

      final snapshot = await query.get();
      final drivers = <DriverModel>[];

      for (var doc in snapshot.docs) {
        final driver = DriverModel.fromJson(doc.data());
        final distance = _calculateDistance(
          location.latitude,
          location.longitude,
          driver.location.latitude,
          driver.location.longitude,
        );

        if (distance <= radiusInKm) {
          drivers.add(driver);
        }
      }

      drivers.sort((a, b) => _calculateDistance(
            location.latitude,
            location.longitude,
            a.location.latitude,
            a.location.longitude,
          ).compareTo(
            _calculateDistance(
              location.latitude,
              location.longitude,
              b.location.latitude,
              b.location.longitude,
            ),
          ));

      return drivers;
    } catch (e) {
      throw Exception('Failed to find nearby drivers: $e');
    }
  }

  @override
  Future<DriverAssignmentModel> assignDriver(String rideId, String driverId) async {
    try {
      final assignmentId = firestore.collection('assignments').doc().id;
      final assignmentData = {
        'assignmentId': assignmentId,
        'rideId': rideId,
        'driverId': driverId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore.collection('assignments').doc(assignmentId).set(assignmentData);

      return DriverAssignmentModel.fromJson({
        ...assignmentData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to assign driver: $e');
    }
  }

  @override
  Stream<LocationPoint> getDriverLocationStream(String driverId) {
    return firestore.collection('drivers').doc(driverId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Driver not found');
      }
      final data = doc.data() as Map<String, dynamic>;
      final location = data['location'] as Map<String, dynamic>? ?? {};
      return LocationPoint(
        latitude: (location['latitude'] ?? 0.0) as double,
        longitude: (location['longitude'] ?? 0.0) as double,
        address: (location['address'] ?? '') as String,
      );
    });
  }

  @override
  Future<void> updateDriverLocation(String driverId, LocationPoint location) async {
    try {
      await firestore.collection('drivers').doc(driverId).update({
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': location.address,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      throw Exception('Failed to update driver location: $e');
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
