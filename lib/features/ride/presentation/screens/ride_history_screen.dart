// lib/features/ride/presentation/screens/ride_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../domain/entities/ride_entity.dart';
import '../bloc/ride_bloc.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});
  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) async {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(AppConstants.keyUserId) ?? '';
        return sl<RideBloc>()..add(LoadRideHistoryEvent(userId));
      }(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Ride History')),
        body: BlocBuilder<RideBloc, RideState>(
          builder: (context, state) {
            if (state is RideLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is RideHistoryLoadedState) {
              if (state.rides.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🚗', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text('No rides yet',
                          style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 8),
                      Text('Your completed rides will appear here.',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.rides.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _RideHistoryCard(ride: state.rides[i]),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _RideHistoryCard extends StatelessWidget {
  final RideEntity ride;
  const _RideHistoryCard({required this.ride});

  String get _vehicleEmoji {
    switch (ride.vehicleType) {
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_vehicleEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ride.pickup.address} → ${ride.destination.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge,
                    ),
                    Text(
                      ride.requestedAt != null
                          ? _formatDate(ride.requestedAt!)
                          : '',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              RideStatusBadge(status: ride.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('🧑 ${ride.passengers}', 'pax'),
              const SizedBox(width: 12),
              if (ride.distanceKm != null)
                _infoChip(
                    '📏 ${ride.distanceKm!.toStringAsFixed(1)} km', ''),
              const Spacer(),
              Text(
                ride.actualPrice != null
                    ? 'GHS ${ride.actualPrice!.toStringAsFixed(2)}'
                    : 'N/A',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
