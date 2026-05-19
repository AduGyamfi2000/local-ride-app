// lib/features/ride/data/models/ride_model.dart

import '../../domain/entities/ride_entity.dart';

class LocationPointModel extends LocationPoint {
  const LocationPointModel({
    required super.lat,
    required super.lng,
    required super.address,
  });

  factory LocationPointModel.fromJson(Map<String, dynamic> json) =>
      LocationPointModel(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        address: json['address'] ?? '',
      );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng, 'address': address};

  factory LocationPointModel.fromEntity(LocationPoint e) =>
      LocationPointModel(lat: e.lat, lng: e.lng, address: e.address);
}

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.userId,
    super.driverId,
    super.driverName,
    super.driverPhone,
    super.driverVehicle,
    required super.vehicleType,
    required super.pickup,
    required super.destination,
    super.passengers,
    required super.status,
    super.estimatedPrice,
    super.actualPrice,
    super.distanceKm,
    super.driverProfilePic,
    super.requestedAt,
    super.acceptedAt,
    super.completedAt,
    super.isSyncedOffline,
    super.driverLat,
    super.driverLng,
    super.rating,
    super.notes,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) => RideModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        driverId: json['driverId'],
        driverName: json['driverName'],
        driverPhone: json['driverPhone'],
        driverVehicle: json['driverVehicle'],
        vehicleType: json['vehicleType'] ?? 'taxi',
        pickup: LocationPointModel.fromJson(
            Map<String, dynamic>.from(json['pickup'])),
        destination: LocationPointModel.fromJson(
            Map<String, dynamic>.from(json['destination'])),
        passengers: json['passengers'] ?? 1,
        status: json['status'] ?? 'searching',
        estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
        actualPrice: (json['actualPrice'] as num?)?.toDouble(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        driverProfilePic: json['driverProfilePic'],
        requestedAt: json['requestedAt'] != null
            ? DateTime.tryParse(json['requestedAt'])
            : null,
        acceptedAt: json['acceptedAt'] != null
            ? DateTime.tryParse(json['acceptedAt'])
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'])
            : null,
        isSyncedOffline: json['isSyncedOffline'] ?? true,
        driverLat: (json['driverLat'] as num?)?.toDouble(),
        driverLng: (json['driverLng'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toDouble(),
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'driverVehicle': driverVehicle,
        'vehicleType': vehicleType,
        'pickup': LocationPointModel.fromEntity(pickup).toJson(),
        'destination': LocationPointModel.fromEntity(destination).toJson(),
        'passengers': passengers,
        'status': status,
        'estimatedPrice': estimatedPrice,
        'actualPrice': actualPrice,
        'distanceKm': distanceKm,
        'driverProfilePic': driverProfilePic,
        'requestedAt': requestedAt?.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'isSyncedOffline': isSyncedOffline,
        'driverLat': driverLat,
        'driverLng': driverLng,
        'rating': rating,
        'notes': notes,
      };
}
