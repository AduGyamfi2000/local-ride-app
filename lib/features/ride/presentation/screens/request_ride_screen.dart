// lib/features/ride/presentation/screens/request_ride_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../domain/entities/ride_entity.dart';
import '../bloc/ride_bloc.dart';

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  final _pickupController = TextEditingController();
  final _destController = TextEditingController();

  String _selectedVehicle = 'Taxi';
  int _passengers = 1;
  bool _loadingPickup = false;
  bool _isOnline = true;

  LocationPoint? _pickupPoint;
  LocationPoint? _destPoint;

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _loadingPickup = true);
    final result = await sl<LocationService>().getCurrentLocation();
    if (result != null) {
      setState(() {
        _pickupController.text = result.address;
        _pickupPoint = LocationPoint(
          lat: result.position.latitude,
          lng: result.position.longitude,
          address: result.address,
        );
      });
    }
    setState(() => _loadingPickup = false);
  }

  double _estimatePrice() {
    if (_pickupPoint == null || _destPoint == null) return 0;
    final dist = sl<LocationService>()
        .calculateDistance(_pickupPoint!.latLng, _destPoint!.latLng);
    final base = AppConstants.baseFare[_selectedVehicle] ?? 3.0;
    final rate = AppConstants.pricePerKm[_selectedVehicle] ?? 2.5;
    return base + (dist * rate);
  }

  bool get _canRequest =>
      _pickupPoint != null &&
      _destPoint != null &&
      _pickupController.text.isNotEmpty &&
      _destController.text.isNotEmpty;

  @override
  void dispose() {
    _pickupController.dispose();
    _destController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RideBloc>(),
      child: BlocConsumer<RideBloc, RideState>(
        listener: (context, state) {
          if (state is RideRequestedState) {
            if (state.isOffline) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📴 No internet. Ride request saved offline!'),
                  backgroundColor: AppColors.warning,
                ),
              );
              context.pop();
            } else {
              context.go(AppRoutes.rideTracking, extra: state.ride.id);
            }
          } else if (state is RideErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Book a Ride'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Column(
            children: [
              if (!_isOnline) const OfflineBanner(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle type selection
                      Text('Choose Vehicle', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 14),
                      Row(
                        children: AppConstants.vehicleTypes.map((v) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: v != AppConstants.vehicleTypes.last ? 10 : 0,
                              ),
                              child: _VehicleCard(
                                type: v,
                                isSelected: _selectedVehicle == v,
                                onTap: () => setState(() => _selectedVehicle = v),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Location inputs
                      Text('Where to?', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 14),

                      // Pickup
                      _locationField(
                        controller: _pickupController,
                        label: 'Pickup Location',
                        icon: Icons.my_location_rounded,
                        iconColor: AppColors.secondary,
                        isLoading: _loadingPickup,
                        hint: 'Your current location',
                        onGpsPressed: _detectCurrentLocation,
                        onChanged: (val) {
                          if (val.length > 3) {
                            _pickupPoint = LocationPoint(
                              lat: 6.6 + (val.length * 0.001),
                              lng: -1.6 + (val.length * 0.001),
                              address: val,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Destination
                      _locationField(
                        controller: _destController,
                        label: 'Destination',
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.error,
                        hint: 'Where are you going?',
                        onChanged: (val) {
                          if (val.length > 3) {
                            _destPoint = LocationPoint(
                              lat: 6.7 + (val.length * 0.001),
                              lng: -1.5 + (val.length * 0.001),
                              address: val,
                            );
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Passengers
                      Text('Passengers', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people_rounded,
                                color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text('Number of passengers',
                                style: AppTextStyles.bodyLarge),
                            const Spacer(),
                            _counterButton(
                              Icons.remove_rounded,
                              () => setState(
                                  () => _passengers = (_passengers - 1).clamp(1, 6)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_passengers',
                                style: AppTextStyles.headlineLarge,
                              ),
                            ),
                            _counterButton(
                              Icons.add_rounded,
                              () => setState(
                                  () => _passengers = (_passengers + 1).clamp(1, 6)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Price estimate
                      if (_canRequest) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.secondary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Text('💰', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estimated Price',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'GHS ${_estimatePrice().toStringAsFixed(2)}',
                                    style: AppTextStyles.headlineLarge.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _selectedVehicle,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '$_passengers passenger(s)',
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Offline notice
                      if (!_isOnline)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.wifi_off_rounded,
                                  color: AppColors.warning, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You are offline. Your request will be saved and sent when you are connected.',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom action
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: AppButton(
                  label: _isOnline ? 'Request Ride 🚗' : 'Save Ride Request 📴',
                  isLoading: state is RideLoading,
                  onPressed: _canRequest ? () => _submitRequest(context) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest(BuildContext context) async {
    if (!_canRequest) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(AppConstants.keyUserId) ?? 'user_1';

    final ride = RideEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      vehicleType: _selectedVehicle,
      pickup: _pickupPoint!,
      destination: _destPoint!,
      passengers: _passengers,
      status: AppConstants.rideStatusSearching,
      estimatedPrice: _estimatePrice(),
      requestedAt: DateTime.now(),
    );

    context.read<RideBloc>().add(RequestRideEvent(ride));
  }

  Widget _locationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    String? hint,
    bool isLoading = false,
    VoidCallback? onGpsPressed,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.surfaceVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.surfaceVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            prefixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 22),
            suffixIcon: onGpsPressed != null
                ? IconButton(
                    icon: const Icon(Icons.gps_fixed_rounded,
                        color: AppColors.primary),
                    onPressed: onGpsPressed,
                    tooltip: 'Use GPS',
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case 'Taxi':
        return Icons.local_taxi_rounded;
      case 'Motorcycle':
        return Icons.two_wheeler_rounded;
      case 'Tricycle':
        return Icons.agriculture_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  Color get _color {
    switch (type) {
      case 'Taxi':
        return AppColors.taxiColor;
      case 'Motorcycle':
        return AppColors.motorcycleColor;
      case 'Tricycle':
        return AppColors.tricycleColor;
      default:
        return AppColors.primary;
    }
  }

  String get _emoji {
    switch (type) {
      case 'Taxi':
        return '🚕';
      case 'Motorcycle':
        return '🏍';
      case 'Tricycle':
        return '🛺';
      default:
        return '🚗';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _color.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _color : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              type,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? _color : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'GHS ${AppConstants.baseFare[type]?.toStringAsFixed(0) ?? '0'}+',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                color: isSelected ? _color : AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
