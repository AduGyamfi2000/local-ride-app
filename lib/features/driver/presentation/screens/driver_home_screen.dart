// lib/features/driver/presentation/screens/driver_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../ride/domain/entities/ride_entity.dart';
import '../bloc/driver_bloc.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  Timer? _simulationTimer;
  int _selectedTab = 0;

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverBloc>(),
      child: BlocConsumer<DriverBloc, DriverState>(
        listener: (context, state) {
          if (state is TripCompletedState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '🎉 Trip done! +GHS ${state.fare.toStringAsFixed(2)}'),
              backgroundColor: AppColors.success,
            ));
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: state is IncomingRideState
                ? _IncomingRideOverlay(
                    ride: state.ride,
                    onAccept: () =>
                        context.read<DriverBloc>().add(AcceptRideRequestEvent(
                              'driver_1',
                              state.ride.id,
                            )),
                    onReject: () => context
                        .read<DriverBloc>()
                        .add(RejectRideRequestEvent(state.ride.id)),
                  )
                : _buildMain(context, state),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (i) {
              setState(() => _selectedTab = i);
              if (i == 1) context.push(AppRoutes.driverEarnings);
              if (i == 2) context.push(AppRoutes.profile);
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money_rounded), label: 'Earnings'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMain(BuildContext context, DriverState state) {
    final isOnline = state is DriverOnlineState;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, Driver 👋',
                            style: AppTextStyles.bodyMedium),
                        Text('Kwame Asante',
                            style: AppTextStyles.headlineLarge),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOnline
                                  ? AppColors.success
                                  : AppColors.textHint,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              color: isOnline
                                  ? AppColors.success
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Online/Offline toggle — BIG button for accessibility
                GestureDetector(
                  onTap: () {
                    if (isOnline) {
                      context.read<DriverBloc>().add(
                          ToggleOnlineEvent('driver_1', false));
                    } else {
                      context.read<DriverBloc>().add(
                          ToggleOnlineEvent('driver_1', true));
                      _simulateIncomingRide(context);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOnline
                            ? [AppColors.success, const Color(0xFF1B5E20)]
                            : [AppColors.textHint, const Color(0xFF424242)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (isOnline ? AppColors.success : AppColors.textHint)
                              .withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isOnline ? '🟢' : '🔴',
                          style: const TextStyle(fontSize: 52),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isOnline ? 'YOU ARE ONLINE' : 'YOU ARE OFFLINE',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isOnline
                              ? 'Waiting for ride requests...'
                              : 'Tap to go online and start earning',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                if (state is DriverOnlineState) ...[
                  Row(
                    children: [
                      Expanded(
                          child: _statCard('💰 Today',
                              'GHS ${state.todayEarnings.toStringAsFixed(2)}',
                              AppColors.secondary)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _statCard(
                              '🚗 Trips', '${state.tripsToday}', AppColors.primary)),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // Vehicle info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Row(
                    children: [
                      const Text('🚕', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Toyota Corolla',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16)),
                          const Text('GR-1234-20',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: AppColors.textSecondary,
                                  fontSize: 14)),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.primary, size: 18),
                          const Text(' 4.8',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }

  void _simulateIncomingRide(BuildContext context) {
    _simulationTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      context.read<DriverBloc>().add(IncomingRideRequestEvent(
            const RideEntity(
              id: 'ride_sim_1',
              userId: 'user_1',
              vehicleType: 'Taxi',
              pickup: LocationPoint(lat: 6.69, lng: -1.62, address: 'Kejetia Market'),
              destination: LocationPoint(lat: 6.71, lng: -1.58, address: 'KNUST Gate'),
              passengers: 2,
              status: 'searching',
              estimatedPrice: 15.50,
            ),
          ));
    });
  }
}

class _IncomingRideOverlay extends StatefulWidget {
  final RideEntity ride;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingRideOverlay({
    required this.ride,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_IncomingRideOverlay> createState() => _IncomingRideOverlayState();
}

class _IncomingRideOverlayState extends State<_IncomingRideOverlay> {
  int _countdown = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        widget.onReject();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text('New Ride Request!', style: AppTextStyles.displayMedium),
          const SizedBox(height: 8),
          Text('Auto-reject in $_countdown seconds',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              children: [
                _row('📍 Pickup', widget.ride.pickup.address),
                const Divider(height: 20),
                _row('🏁 Drop-off', widget.ride.destination.address),
                const Divider(height: 20),
                _row('🧑 Passengers', '${widget.ride.passengers}'),
                const Divider(height: 20),
                _row('💰 Est. Fare',
                    'GHS ${widget.ride.estimatedPrice?.toStringAsFixed(2) ?? "?"}'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reject',
                  variant: AppButtonVariant.outlined,
                  icon: Icons.close_rounded,
                  onPressed: widget.onReject, text: '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  label: 'Accept',
                  variant: AppButtonVariant.secondary,
                  icon: Icons.check_rounded,
                  onPressed: widget.onAccept, text: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ],
    );
  }
}
