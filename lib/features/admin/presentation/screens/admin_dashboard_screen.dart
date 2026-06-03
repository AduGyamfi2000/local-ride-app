// lib/features/admin/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/offline_banner.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Rides'),
            Tab(text: 'Drivers'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RidesTab(),
          _DriversTab(),
          _StatsTab(),
        ],
      ),
    );
  }
}

class _RidesTab extends StatelessWidget {
  final List<Map<String, dynamic>> _rides = [
    {
      'id': '#001',
      'from': 'Market Circle',
      'to': 'Suame Magazine',
      'status': 'in_progress',
      'driver': 'Kwame A.',
      'fare': 'GHS 12.50',
      'vehicle': '🚕'
    },
    {
      'id': '#002',
      'from': 'Kejetia',
      'to': 'KNUST',
      'status': 'searching',
      'driver': 'Unassigned',
      'fare': 'GHS 15.00',
      'vehicle': '🏍'
    },
    {
      'id': '#003',
      'from': 'Airport',
      'to': 'City Centre',
      'status': 'completed',
      'driver': 'Kojo M.',
      'fare': 'GHS 28.00',
      'vehicle': '🚕'
    },
    {
      'id': '#004',
      'from': 'Bantama',
      'to': 'Asokwa',
      'status': 'accepted',
      'driver': 'Ama S.',
      'fare': 'GHS 8.00',
      'vehicle': '🛺'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = _rides[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(r['vehicle'], style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(r['id'],
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const Spacer(),
                  RideStatusBadge(status: r['status']),
                ],
              ),
              const SizedBox(height: 8),
              Text('${r['from']} → ${r['to']}',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_rounded,
                      size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(r['driver'], style: AppTextStyles.caption),
                  const Spacer(),
                  Text(r['fare'],
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.secondary)),
                ],
              ),
              if (r['status'] == 'searching') ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _showAssignDialog(context, r['id']),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Assign Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAssignDialog(BuildContext context, String rideId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign Driver to $rideId',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            ...['Kwame Asante', 'Kojo Mensah', 'Ama Serwaa'].map(
              (name) => ListTile(
                leading: const CircleAvatar(child: Text('👤')),
                title: Text(name,
                    style: const TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
                subtitle: const Text('Available · ⭐ 4.7',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name assigned to $rideId')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriversTab extends StatelessWidget {
  final List<Map<String, dynamic>> _drivers = [
    {
      'name': 'Kwame Asante',
      'vehicle': 'Toyota Corolla',
      'plate': 'GR-1234-20',
      'status': 'online',
      'rating': 4.8,
      'trips': 342
    },
    {
      'name': 'Kojo Mensah',
      'vehicle': 'Honda CB125',
      'plate': 'AK-5678-21',
      'status': 'busy',
      'rating': 4.5,
      'trips': 189
    },
    {
      'name': 'Ama Serwaa',
      'vehicle': 'Tricycle (Keke)',
      'plate': 'KS-9012-22',
      'status': 'offline',
      'rating': 4.9,
      'trips': 521
    },
  ];

  Color _statusColor(String s) {
    switch (s) {
      case 'online': return AppColors.success;
      case 'busy': return AppColors.warning;
      default: return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _drivers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final d = _drivers[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Text('👤', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['name'],
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text('${d['vehicle']} · ${d['plate']}',
                        style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: AppColors.primary),
                        Text(' ${d['rating']}  ·  ',
                            style: AppTextStyles.caption),
                        Text('${d['trips']} trips',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(d['status']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  d['status'].toString().toUpperCase(),
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(d['status'])),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _statCard('Total Rides Today', '47', '📊', AppColors.primary),
          const SizedBox(height: 12),
          _statCard('Active Drivers', '12', '🚗', AppColors.secondary),
          const SizedBox(height: 12),
          _statCard('Revenue Today', 'GHS 842.50', '💰', AppColors.accent),
          const SizedBox(height: 12),
          _statCard('Pending (Offline)', '3', '📴', AppColors.warning),
          const SizedBox(height: 12),
          _statCard('Completed Rides', '38', '✅', AppColors.success),
          const SizedBox(height: 12),
          _statCard('Cancelled Rides', '6', '❌', AppColors.error),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textSecondary)),
          ),
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
}
