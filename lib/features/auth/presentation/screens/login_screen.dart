// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullPhone = '';
  bool _phoneValid = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            context.push(AppRoutes.otp, extra: state.phoneNumber);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) => Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome to\nRuralRide 👋',
                      style: AppTextStyles.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your phone number to get started.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Phone number input
                    Text(
                      'Phone Number',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IntlPhoneField(
                      initialCountryCode: 'GH',
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: '24 123 4567',
                        hintStyle: const TextStyle(color: AppColors.textHint, fontFamily: 'Nunito'),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.surfaceVariant, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.surfaceVariant, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (phone) {
                        setState(() {
                          _fullPhone = phone.completeNumber;
                          _phoneValid = phone.isValidNumber();
                        });
                      },
                      countries: const ['GH', 'NG', 'KE', 'UG', 'TZ', 'CM', 'SN', 'CI'],
                    ),
                    const SizedBox(height: 8),

                    // Info text
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'We will send you a 6-digit code to verify your number.',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Send OTP Code',
                      icon: Icons.sms_rounded,
                      isLoading: state is AuthLoading,
                      onPressed: _phoneValid
                          ? () => context.read<AuthBloc>().add(SendOtpEvent(_fullPhone))
                          : null, text: '',
                    ),
                    const SizedBox(height: 24),

                    // Language selector
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.language_rounded, size: 16, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          const Text(
                            'Language: ',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.textHint,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showLanguageDialog(context),
                            child: const Text(
                              'English | Twi',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
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
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Language', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),
            _langTile('🇬🇧', 'English', 'en'),
            const Divider(height: 1),
            _langTile('🇬🇭', 'Twi (Ghana)', 'tw'),
          ],
        ),
      ),
    );
  }

  Widget _langTile(String flag, String name, String code) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(name, style: AppTextStyles.bodyLarge),
      onTap: () => Navigator.pop(context),
    );
  }
}
