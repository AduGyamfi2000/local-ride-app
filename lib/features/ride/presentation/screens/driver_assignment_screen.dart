import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rural_ride/features/driver/domain/entities/driver_entity.dart';
import 'package:rural_ride/features/driver/presentation/bloc/driver_assignment_bloc.dart';
import 'package:rural_ride/features/ride/domain/entities/ride_entity.dart';

import '../../../../core/widgets/app_button.dart';

import '../widgets/driver_tracking_widget.dart';

class DriverAssignmentScreen extends StatefulWidget {
  final String rideId;
  final LocationPoint pickupLocation;
  final LocationPoint dropoffLocation;

  const DriverAssignmentScreen({
    Key? key,
    required this.rideId,
    required this.pickupLocation,
    required this.dropoffLocation,
  }) : super(key: key);

  @override
  State<DriverAssignmentScreen> createState() => _DriverAssignmentScreenState();
}

class _DriverAssignmentScreenState extends State<DriverAssignmentScreen> {
  DriverEntity? _selectedDriver;
  String _eta = '--:--';

  @override
  void initState() {
    super.initState();
    context.read<DriverAssignmentBloc>().add(
          FindNearbyDriversEvent(
            location: widget.pickupLocation,
            radiusInKm: 5.0,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finding Driver'),
        elevation: 0,
      ),
      body: BlocListener<DriverAssignmentBloc, DriverAssignmentState>(
        listener: (context, state) {
          if (state is DriverAssigned) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Driver assigned successfully!')),
            );
            Navigator.pop(context, true);
          } else if (state is DriverAssignmentFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Drivers Nearby',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                BlocBuilder<DriverAssignmentBloc, DriverAssignmentState>(
                  builder: (context, state) {
                    if (state is DriverAssignmentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is DriversFound) {
                      if (state.drivers.isEmpty) {
                        return const Center(
                          child: Text('No drivers available nearby'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.drivers.length,
                        itemBuilder: (context, index) {
                          final driver = state.drivers[index];
                          final isSelected = _selectedDriver?.id == driver.id;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDriver = driver),
                            child: Card(
                              color: isSelected ? Colors.blue[50] : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(driver.photoUrl),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            driver.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            driver.vehicle,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(
                                                driver.rating.toStringAsFixed(1),
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const Center(child: Text('Failed to load drivers'));
                  },
                ),
                const SizedBox(height: 32),
                if (_selectedDriver != null) ...[
                  const Text(
                    'Driver Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DriverTrackingWidget(
                    driver: _selectedDriver!,
                    driverLocation: _selectedDriver!.location,
                    pickupLocation: widget.pickupLocation,
                    eta: _eta,
                  ),
                  const SizedBox(height: 24),
                ],
                BlocBuilder<DriverAssignmentBloc, DriverAssignmentState>(
                  builder: (context, state) {
                    final isLoading = state is DriverAssignmentLoading;
                    return AppButton(
                      onPressed: _selectedDriver != null && !isLoading
                          ? () => _assignDriver()
                          : null,
                      text: isLoading ? 'Assigning...' : 'Confirm Driver', label: '',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _assignDriver() {
    if (_selectedDriver != null) {
      context.read<DriverAssignmentBloc>().add(
            AssignDriverEvent(
              rideId: widget.rideId,
              driverId: _selectedDriver!.id,
            ),
          );
    }
  }
}
