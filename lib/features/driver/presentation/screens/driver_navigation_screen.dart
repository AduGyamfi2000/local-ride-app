// lib/features/driver/presentation/screens/driver_navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';

class DriverNavigationScreen extends StatefulWidget {
  const DriverNavigationScreen({super.key});
  @override
  State<DriverNavigationScreen> createState() => _DriverNavigationScreenState();
}

class _DriverNavigationScreenState extends State<DriverNavigationScreen> {
  bool _pickedUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Navigation')),
      body: Column(
        children: [
          // Map placeholder
          Container(
            height: 300,
            color: const Color(0xFFE8E8E8),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 300),
                  painter: _NavMapPainter(),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_pickedUp ? '🏁' : '📍',
                          style: const TextStyle(fontSize: 52)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _pickedUp
                              ? 'Navigate to Destination'
                              : 'Navigate to Pickup',
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Column(
                      children: [
                        _navRow(Icons.my_location_rounded,
                            _pickedUp ? 'User picked up ✅' : 'Kejetia Market',
                            AppColors.secondary),
                        const Divider(height: 20),
                        _navRow(Icons.flag_rounded, 'KNUST Gate',
                            AppColors.error),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!_pickedUp)
                    AppButton(
                      label: 'Arrived at Pickup',
                      icon: Icons.person_pin_circle_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => setState(() => _pickedUp = true), text: '',
                    ),
                  if (_pickedUp) ...[
                    AppButton(
                      label: 'Start Trip',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {}, text: '',
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'End Trip & Collect Fare',
                      icon: Icons.stop_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.pop(), text: '',
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

  Widget _navRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: AppTextStyles.bodyLarge)),
      ],
    );
  }
}

class _NavMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceVariant.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Draw route line
    final routePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.8),
        Offset(size.width * 0.8, size.height * 0.2),
        routePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// lib/features/driver/presentation/screens/driver_earnings_screen.dart

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Earnings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Total card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.secondary, Color(0xFF0D4A26)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  const Text('Total Earnings',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white70,
                          fontSize: 14)),
                  const Text('GHS 1,248.50',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniStat('Today', 'GHS 85.00'),
                      _miniStat('This Week', 'GHS 420.00'),
                      _miniStat('Trips', '342'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader('Recent Trips'),
            const SizedBox(height: 12),
            ...[
              _earningTile('Kejetia → KNUST', 'Today 2:30 PM', 'GHS 15.50'),
              _earningTile('Suame → Asokwa', 'Today 11:00 AM', 'GHS 9.00'),
              _earningTile('Airport → City', 'Yesterday 4:00 PM', 'GHS 28.00'),
              _earningTile('Bantama → Asem', 'Yesterday 9:00 AM', 'GHS 7.50'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Nunito', color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTextStyles.headlineMedium),
    );
  }

  Widget _earningTile(String route, String time, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          const Text('🚕', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(route, style: AppTextStyles.bodyLarge),
                Text(time, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(amount,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.secondary)),
        ],
      ),
    );
  }
}
