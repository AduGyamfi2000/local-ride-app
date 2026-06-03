// lib/features/auth/presentation/screens/otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  int _countdown = 60;
  Timer? _timer;
  String _selectedRole = 'user'; // default role

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
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
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            final role = state.user.role;
            switch (role) {
              case 'driver':
                context.go(AppRoutes.driverHome);
                break;
              case 'admin':
                context.go(AppRoutes.adminDashboard);
                break;
              default:
                context.go(AppRoutes.userHome);
            }
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📱', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 20),
                  Text('Enter OTP Code', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to\n${widget.phoneNumber}',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),

                  // OTP input
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 60,
                      fieldWidth: 52,
                      activeFillColor: AppColors.surface,
                      selectedFillColor: AppColors.surface,
                      inactiveFillColor: AppColors.surface,
                      activeColor: AppColors.primary,
                      selectedColor: AppColors.primary,
                      inactiveColor: AppColors.surfaceVariant,
                    ),
                    enableActiveFill: true,
                    onCompleted: (otp) => setState(() => _otp = otp),
                    onChanged: (value) => setState(() => _otp = value),
                    textStyle: AppTextStyles.headlineLarge,
                  ),

                  const SizedBox(height: 16),

                  // Role selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I am a...',
                          style: AppTextStyles.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _roleChip('🧑 Rider', 'user'),
                            const SizedBox(width: 10),
                            _roleChip('🚗 Driver', 'driver'),
                            const SizedBox(width: 10),
                            _roleChip('⚙️ Admin', 'admin'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Verify & Login',
                    icon: Icons.check_circle_rounded,
                    isLoading: state is AuthLoading,
                    onPressed: _otp.length == 6
                        ? () => context.read<AuthBloc>().add(
                              VerifyOtpEvent(
                                phoneNumber: widget.phoneNumber,
                                otp: _otp,
                                role: _selectedRole,
                              ),
                            )
                        : null, text: '',
                  ),
                  const SizedBox(height: 24),

                  // Resend
                  Center(
                    child: _countdown > 0
                        ? Text(
                            'Resend code in $_countdown seconds',
                            style: AppTextStyles.bodyMedium,
                          )
                        : GestureDetector(
                            onTap: () {
                              setState(() => _countdown = 60);
                              _startTimer();
                            },
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String label, String value) {
    final selected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Placeholder for role select screen (accessed after auth if needed separately)
// lib/features/auth/presentation/screens/role_select_screen.dart

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('Role Select Screen', style: AppTextStyles.headlineLarge),
      ),
    );
  }
}
