import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String vehicleType;
  final String vehiclePlate;
  final String status; // online, offline, busy
  final double? currentLat;
  final double? currentLng;
  final double rating;
  final int totalTrips;
  final double totalEarnings;
  final double todayEarnings;

  const DriverEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalEarnings = 0.0,
    this.todayEarnings = 0.0,
  });

  DriverEntity copyWith({
    String? status,
    double? currentLat,
    double? currentLng,
    double? todayEarnings,
    int? totalTrips,
  }) =>
      DriverEntity(
        id: id, name: name, phone: phone,
        vehicleType: vehicleType, vehiclePlate: vehiclePlate,
        status: status ?? this.status,
        currentLat: currentLat ?? this.currentLat,
        currentLng: currentLng ?? this.currentLng,
        rating: rating, totalEarnings: totalEarnings,
        todayEarnings: todayEarnings ?? this.todayEarnings,
        totalTrips: totalTrips ?? this.totalTrips,
      );

  @override
  List<Object?> get props => [id, status];
}
