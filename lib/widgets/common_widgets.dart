// lib/widgets/common_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_theme.dart';

// ── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;
  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12, vertical: small ? 3 : 5),
    decoration: BoxDecoration(
      color: AppTheme.statusBg(status),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.statusColor(status).withOpacity(0.4)),
    ),
    child: Text(status,
        style: TextStyle(color: AppTheme.statusColor(status),
            fontSize: small ? 11 : 12, fontWeight: FontWeight.w700)),
  );
}

// ── Loading ───────────────────────────────────────────────────────────────────
class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.accent)),
      if (message != null) ...[
        const SizedBox(height: 14),
        Text(message!, style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
      ],
    ]),
  );
}

// ── Error ─────────────────────────────────────────────────────────────────────
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.08), shape: BoxShape.circle),
          child: const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.error),
        ),
        const SizedBox(height: 16),
        const Text('Terjadi Kesalahan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSec, height: 1.5)),
        if (onRetry != null) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi')),
        ],
      ]),
    ),
  );
}

// ── Empty ─────────────────────────────────────────────────────────────────────
class EmptyWidget extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  const EmptyWidget({super.key, required this.title, required this.subtitle,
      this.icon = Icons.inbox_outlined, this.onAction, this.actionLabel});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: AppTheme.accentLight, shape: BoxShape.circle),
          child: Icon(icon, size: 44, color: AppTheme.accent),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSec, height: 1.5)),
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!)),
        ],
      ]),
    ),
  );
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  const InfoRow({super.key, required this.icon, required this.label,
      required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 17, color: AppTheme.accent),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(label, style: const TextStyle(
            fontSize: 11, color: AppTheme.textSec, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.textPri)),
      ])),
    ]),
  );
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  const SectionHeader({super.key, required this.title,
      this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 4, height: 20,
        decoration: BoxDecoration(color: AppTheme.accent,
            borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPri)),
    if (trailing != null) ...[
      const Spacer(),
      GestureDetector(onTap: onTrailingTap,
          child: Text(trailing!, style: const TextStyle(
              fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w600))),
    ],
  ]);
}

// ── Role Badge ─────────────────────────────────────────────────────────────────
class RoleBadge extends StatelessWidget {
  final bool isAdmin;
  const RoleBadge({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isAdmin
          ? AppTheme.accent.withOpacity(0.15)
          : const Color(0xFF8E44AD).withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
          color: isAdmin
              ? AppTheme.accent.withOpacity(0.5)
              : const Color(0xFF8E44AD).withOpacity(0.4)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(isAdmin ? Icons.admin_panel_settings : Icons.hotel_class_outlined,
          size: 13,
          color: isAdmin ? AppTheme.accent : const Color(0xFF8E44AD)),
      const SizedBox(width: 5),
      Text(isAdmin ? 'Admin Hotel' : 'Pelanggan',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: isAdmin ? AppTheme.accent : const Color(0xFF8E44AD))),
    ]),
  );
}
