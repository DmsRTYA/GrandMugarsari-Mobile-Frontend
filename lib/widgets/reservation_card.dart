// lib/widgets/reservation_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/reservation_model.dart';
import '../models/app_constants.dart';
import 'app_theme.dart';
import 'common_widgets.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.index = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark]),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: Center(child: Text(
                  reservation.namaTamu.isNotEmpty
                      ? reservation.namaTamu[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppTheme.accent,
                      fontWeight: FontWeight.bold, fontSize: 15),
                )),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(reservation.namaTamu,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis),
                Text(reservation.jenisKamar,
                    style: TextStyle(color: Colors.white.withOpacity(0.65),
                        fontSize: 11)),
              ])),
              StatusBadge(status: reservation.status, small: true),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(children: [
              Row(children: [
                _Chip(icon: Icons.calendar_today,
                    text: '${formatDate(reservation.checkIn)} → ${formatDate(reservation.checkOut)}'),
                const Spacer(),
                _Chip(icon: Icons.nights_stay,
                    text: '${reservation.jumlahMalam}m · ${reservation.jumlahKamar}k'),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Total', style: TextStyle(
                      fontSize: 11, color: AppTheme.textSec)),
                  Text(formatRupiah(reservation.totalHarga),
                      style: const TextStyle(fontSize: 15,
                          fontWeight: FontWeight.bold, color: AppTheme.accent)),
                ])),
                if (onEdit != null)
                  _ActionBtn(icon: Icons.edit_outlined,
                      color: AppTheme.dikonfirmasi, onTap: onEdit!),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  _ActionBtn(icon: Icons.delete_outline,
                      color: AppTheme.error, onTap: onDelete!),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    )
      .animate(delay: Duration(milliseconds: 60 * index))
      .fadeIn(duration: 350.ms)
      .slideY(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
      children: [
    Icon(icon, size: 13, color: AppTheme.textSec),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSec)),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 18),
    ),
  );
}
