// lib/features/ride/presentation/screens/user_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rural_ride/core/services/offline_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../bloc/ride_bloc.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _userName = 'Rider';
  String _userId = '';
  int _pendingCount = 0;
  bool _isOnline = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cached_user');
    if (raw != null) {
      // parse name from cached JSON
    }
    setState(() {
      _userName = prefs.getString('cached_user') != null ? 'User' : 'Rider';
      _userId = prefs.getString(AppConstants.keyUserId) ?? '';
    });

    final pending = await sl<OfflineSyncService>().getPendingCount();
    setState(() {
      _pendingCount = pending;
      _isOnline = pending == 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RideBloc>()..add(LoadActiveRideEvent(_userId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              if (!_isOnline) OfflineBanner(pendingCount: _pendingCount),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(child: _buildHeader()),
                    // Active ride card
                    SliverToBoxAdapter(child: _buildActiveRideCard()),
                    // Quick actions
                    SliverToBoxAdapter(child: _buildQuickActions()),
                    // Recent rides
                    SliverToBoxAdapter(child: _buildRecentRidesSection()),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                _userName,
                style: AppTextStyles.headlineLarge,
              ),
            ],
          ),
          Row(
            children: [
              // Pending indicator
              if (_pendingCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        '$_pendingCount pending',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRideCard() {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        if (state is RideActiveState) {
          return GestureDetector(
            onTap: () => context.push(AppRoutes.rideTracking, extra: state.ride.id),
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🚗 Active Ride',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      RideStatusBadge(status: state.ride.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _tripRow(
                      Icons.my_location_rounded,
                      state.ride.pickup.address,
                      Colors.white70),
                  const SizedBox(height: 8),
                  _tripRow(
                      Icons.location_on_rounded,
                      state.ride.destination.address,
                      Colors.white),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Tap to track →',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (state.ride.estimatedPrice != null)
                        Text(
                          'GHS ${state.ride.estimatedPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _tripRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Nunito',
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Book a Ride'),
          const SizedBox(height: 16),
          // Big CTA button
          GestureDetector(
            onTap: () => context.push(AppRoutes.requestRide),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Text('🚗', style: TextStyle(fontSize: 48)),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request a Ride',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Taxi · Motorcycle · Tricycle',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Vehicle type quick launch
          Row(
            children: [
              Expanded(
                child: BigIconButton(
                  icon: Icons.local_taxi_rounded,
                  label: 'Taxi',
                  color: AppColors.taxiColor,
                  onPressed: () => context.push(AppRoutes.requestRide),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BigIconButton(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Motorcycle',
                  color: AppColors.motorcycleColor,
                  onPressed: () => context.push(AppRoutes.requestRide),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BigIconButton(
                  icon: Icons.agriculture_rounded,
                  label: 'Tricycle',
                  color: AppColors.tricycleColor,
                  onPressed: () => context.push(AppRoutes.requestRide),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRidesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Rides',
            action: 'See All',
            onAction: () => context.push(AppRoutes.rideHistory),
          ),
          const SizedBox(height: 16),
          _recentRideTile(
            emoji: '🚗',
            from: 'Market Circle',
            to: 'Suame Magazine',
            date: 'Today',
            price: 'GHS 12.50',
            status: 'completed',
          ),
          const SizedBox(height: 10),
          _recentRideTile(
            emoji: '🏍',
            from: 'Kejetia',
            to: 'Anloga Junction',
            date: 'Yesterday',
            price: 'GHS 6.00',
            status: 'completed',
          ),
        ],
      ),
    );
  }

  Widget _recentRideTile({
    required String emoji,
    required String from,
    required String to,
    required String date,
    required String price,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$from → $to',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(date, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              RideStatusBadge(status: status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (i) {
        setState(() => _selectedTab = i);
        switch (i) {
          case 1:
            context.push(AppRoutes.rideHistory);
            break;
          case 2:
            context.push(AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}
