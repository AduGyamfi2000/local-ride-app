// lib/features/ride/presentation/screens/ride_tracking_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/offline_banner.dart';

class RideTrackingScreen extends StatefulWidget {
  final String rideId;
  const RideTrackingScreen({super.key, required this.rideId});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  String _currentStatus = AppConstants.rideStatusSearching;
  int _stepIndex = 0;
  Timer? _simulationTimer;

  final List<Map<String, dynamic>> _steps = [
    {
      'status': AppConstants.rideStatusSearching,
      'label': 'Searching for driver...',
      'emoji': '🔍',
      'color': AppColors.statusSearching,
    },
    {
      'status': AppConstants.rideStatusAccepted,
      'label': 'Driver accepted your ride!',
      'emoji': '✅',
      'color': AppColors.statusAccepted,
    },
    {
      'status': AppConstants.rideStatusOnTheWay,
      'label': 'Driver is on the way',
      'emoji': '🚗',
      'color': AppColors.statusOnWay,
    },
    {
      'status': AppConstants.rideStatusArrived,
      'label': 'Driver has arrived!',
      'emoji': '📍',
      'color': AppColors.statusArrived,
    },
    {
      'status': AppConstants.rideStatusInProgress,
      'label': 'Ride in progress',
      'emoji': '▶️',
      'color': AppColors.statusArrived,
    },
    {
      'status': AppConstants.rideStatusCompleted,
      'label': 'Ride completed! 🎉',
      'emoji': '🏁',
      'color': AppColors.statusCompleted,
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateRideProgress();
  }

  void _simulateRideProgress() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_stepIndex < _steps.length - 1) {
        setState(() {
          _stepIndex++;
          _currentStatus = _steps[_stepIndex]['status'];
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final color = step['color'] as Color;
    final isCompleted = _currentStatus == AppConstants.rideStatusCompleted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Ride'),
        leading: isCompleted
            ? IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () => context.go('/user/home'),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Simulated map area
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.15), AppColors.surfaceVariant],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Fake map grid
                CustomPaint(
                  size: const Size(double.infinity, 240),
                  painter: _MapGridPainter(),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(step['emoji'], style: const TextStyle(fontSize: 60)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          step['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Driver card (shown after accepted)
                  if (_stepIndex >= 1) _buildDriverCard(),
                  const SizedBox(height: 20),

                  // Status timeline
                  _buildStatusTimeline(),
                  const SizedBox(height: 20),

                  // Trip details
                  _buildTripDetails(),
                  const SizedBox(height: 20),

                  // Actions
                  if (!isCompleted)
                    AppButton(
                      label: 'Cancel Ride',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.cancel_rounded,
                      onPressed: () => _showCancelDialog(context), text: '',
                    ),
                  if (isCompleted) ...[
                    AppButton(
                      label: 'Rate Your Driver ⭐',
                      onPressed: () => _showRatingDialog(context), text: '',
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Back to Home',
                      variant: AppButtonVariant.outlined,
                      onPressed: () => context.go('/user/home'), text: '',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Text('👨', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kwame Asante',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
                const Text('Toyota Corolla · GR-1234-20',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary,
                        fontSize: 13)),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.primary, size: 16),
                    const Text(' 4.8',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const Text(' · 342 trips',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            color: AppColors.textHint,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              _actionCircle(Icons.phone_rounded, AppColors.secondary, () {}),
              const SizedBox(height: 8),
              _actionCircle(
                  Icons.message_rounded, AppColors.primary, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCircle(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Column(
      children: List.generate(_steps.length, (i) {
        final done = i <= _stepIndex;
        final active = i == _stepIndex;
        final s = _steps[i];
        final c = s['color'] as Color;
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: done ? c : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    done ? Icons.check_rounded : Icons.circle_outlined,
                    color: done ? Colors.white : AppColors.textHint,
                    size: 18,
                  ),
                ),
                if (i < _steps.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: done && i < _stepIndex
                        ? c
                        : AppColors.surfaceVariant,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  s['label'],
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: active ? 15 : 14,
                    color: done ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTripDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          _detailRow('📍 Pickup', 'Market Circle, Kumasi'),
          const Divider(height: 20),
          _detailRow('🏁 Destination', 'Suame Magazine'),
          const Divider(height: 20),
          _detailRow('🚗 Vehicle', 'Taxi'),
          const Divider(height: 20),
          _detailRow('💰 Est. Price', 'GHS 12.50'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textSecondary,
                fontSize: 14)),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 14)),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Ride?',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to cancel this ride?',
            style: TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, Keep')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              context.go('/user/home');
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 5;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏁', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('Rate your trip',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => GestureDetector(
                          onTap: () => setS(() => rating = i + 1),
                          child: Icon(
                            i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        )),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Submit Rating',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/user/home');
                }, text: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceVariant.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
