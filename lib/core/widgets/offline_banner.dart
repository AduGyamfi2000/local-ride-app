// lib/core/widgets/offline_banner.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  final int pendingCount;
  const OfflineBanner({super.key, this.pendingCount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: AppColors.warning,
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pendingCount > 0
                  ? 'No internet. $pendingCount request(s) saved. Will send when connected.'
                  : 'No internet connection',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// lib/core/widgets/ride_status_badge.dart

class RideStatusBadge extends StatelessWidget {
  final String status;
  const RideStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'searching':
        return AppColors.statusSearching;
      case 'accepted':
        return AppColors.statusAccepted;
      case 'on_the_way':
        return AppColors.statusOnWay;
      case 'arrived':
        return AppColors.statusArrived;
      case 'in_progress':
        return AppColors.statusArrived;
      case 'completed':
        return AppColors.statusCompleted;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.textHint;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'searching':
        return '🔍 Searching';
      case 'accepted':
        return '✅ Accepted';
      case 'on_the_way':
        return '🚗 On the Way';
      case 'arrived':
        return '📍 Arrived';
      case 'in_progress':
        return '▶️ In Progress';
      case 'completed':
        return '🎉 Completed';
      case 'cancelled':
        return '❌ Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

// lib/core/widgets/section_header.dart

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineMedium,
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

// lib/core/widgets/app_text_field.dart

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary, size: 22)
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
