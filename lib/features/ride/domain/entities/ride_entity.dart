// lib/features/ride/domain/entities/ride_entity.dart

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPoint extends Equatable {
  final double lat;
  final double lng;
  final String address;

  const LocationPoint({required this.lat, required this.lng, required this.address});

  LatLng get latLng => LatLng(lat, lng);

  @override
  List<Object?> get props => [lat, lng, address];
}

class RideEntity extends Equatable {
  final String id;
  final String userId;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? driverVehicle;
  final String vehicleType; // taxi, motorcycle, tricycle
  final LocationPoint pickup;
  final LocationPoint destination;
  final int passengers;
  final String status;
  final double? estimatedPrice;
  final double? actualPrice;
  final double? distanceKm;
  final String? driverProfilePic;
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final bool isSyncedOffline;
  final double? driverLat;
  final double? driverLng;
  final double? rating;
  final String? notes;

  const RideEntity({
    required this.id,
    required this.userId,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverVehicle,
    required this.vehicleType,
    required this.pickup,
    required this.destination,
    this.passengers = 1,
    required this.status,
    this.estimatedPrice,
    this.actualPrice,
    this.distanceKm,
    this.driverProfilePic,
    this.requestedAt,
    this.acceptedAt,
    this.completedAt,
    this.isSyncedOffline = true,
    this.driverLat,
    this.driverLng,
    this.rating,
    this.notes,
  });

  RideEntity copyWith({
    String? id,
    String? userId,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? driverVehicle,
    String? vehicleType,
    LocationPoint? pickup,
    LocationPoint? destination,
    int? passengers,
    String? status,
    double? estimatedPrice,
    double? actualPrice,
    double? distanceKm,
    String? driverProfilePic,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    bool? isSyncedOffline,
    double? driverLat,
    double? driverLng,
    double? rating,
    String? notes,
  }) {
    return RideEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      vehicleType: vehicleType ?? this.vehicleType,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      passengers: passengers ?? this.passengers,
      status: status ?? this.status,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      distanceKm: distanceKm ?? this.distanceKm,
      driverProfilePic: driverProfilePic ?? this.driverProfilePic,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      isSyncedOffline: isSyncedOffline ?? this.isSyncedOffline,
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, driverId, vehicleType, status, pickup, destination,
        passengers, estimatedPrice,
      ];
}
