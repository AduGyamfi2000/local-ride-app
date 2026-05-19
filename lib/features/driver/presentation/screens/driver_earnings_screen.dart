// lib/features/driver/presentation/screens/driver_earnings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Earnings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Earnings',
                      style: TextStyle(fontFamily: 'Nunito', color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  const Text('GHS 842.50',
                      style: TextStyle(fontFamily: 'Nunito', color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _earningPill('Today', 'GHS 68.00'),
                      const SizedBox(width: 12),
                      _earningPill('This Week', 'GHS 312.50'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Recent Trips', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 14),
            ...List.generate(5, (i) => _tripTile(i)),
          ],
        ),
      ),
    );
  }

  Widget _earningPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Nunito', color: Colors.white70, fontSize: 11)),
          Text(value, style: const TextStyle(fontFamily: 'Nunito', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _tripTile(int i) {
    final trips = [
      {'from': 'Kejetia', 'to': 'Adum', 'price': 'GHS 8.00', 'time': '2h ago', 'km': '2.1 km'},
      {'from': 'Suame', 'to': 'KNUST', 'price': 'GHS 15.00', 'time': '5h ago', 'km': '4.8 km'},
      {'from': 'Asokwa', 'to': 'Bantama', 'price': 'GHS 10.50', 'time': 'Yesterday', 'km': '3.2 km'},
      {'from': 'Airport', 'to': 'Osu', 'price': 'GHS 35.00', 'time': '2 days ago', 'km': '9.5 km'},
      {'from': 'Circle', 'to': 'Lapaz', 'price': 'GHS 12.00', 'time': '3 days ago', 'km': '3.8 km'},
    ];
    final t = trips[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.directions_car_rounded, color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t['from']} → ${t['to']}', style: AppTextStyles.bodyLarge),
                Text('${t['km']} · ${t['time']}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(t['price']!,
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.secondary)),
        ],
      ),
    );
  }
}
