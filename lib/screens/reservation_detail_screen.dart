// lib/screens/reservation_detail_screen.dart
// Halaman detail reservasi lengkap

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reservation_model.dart';
import '../models/app_constants.dart';
import '../providers/reservation_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReservationDetailScreen extends StatelessWidget {
  const ReservationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservation =
        ModalRoute.of(context)!.settings.arguments as Reservation;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF0F3460)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservasi #${reservation.id}',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation.namaTamu,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(status: reservation.status),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/reservations/edit',
                  arguments: reservation,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Hapus',
                onPressed: () => _confirmDelete(context, reservation),
              ),
            ],
          ),

          // ── Body ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Harga Total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF0F3460)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Harga',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          formatRupiah(reservation.totalHarga),
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reservation.jumlahMalam} malam × '
                          '${reservation.jumlahKamar} kamar '
                          '${reservation.jenisKamar}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Tamu
                  _SectionCard(
                    title: 'Informasi Tamu',
                    icon: Icons.person_outline,
                    children: [
                      InfoRow(
                        icon: Icons.person,
                        label: 'Nama Tamu',
                        value: reservation.namaTamu,
                      ),
                      InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: reservation.email,
                      ),
                      InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Telepon',
                        value: reservation.telepon,
                      ),
                      InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'No. Identitas',
                        value: reservation.noIdentitas,
                      ),
                      InfoRow(
                        icon: Icons.group_outlined,
                        label: 'Jumlah Tamu',
                        value: '${reservation.jumlahTamu} orang',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Info Kamar
                  _SectionCard(
                    title: 'Detail Kamar',
                    icon: Icons.hotel_outlined,
                    children: [
                      InfoRow(
                        icon: Icons.bed,
                        label: 'Jenis Kamar',
                        value: reservation.jenisKamar,
                      ),
                      InfoRow(
                        icon: Icons.door_front_door_outlined,
                        label: 'Jumlah Kamar',
                        value: '${reservation.jumlahKamar} kamar',
                      ),
                      InfoRow(
                        icon: Icons.login,
                        label: 'Check-In',
                        value: _formatDate(reservation.checkIn),
                      ),
                      InfoRow(
                        icon: Icons.logout,
                        label: 'Check-Out',
                        value: _formatDate(reservation.checkOut),
                      ),
                      InfoRow(
                        icon: Icons.nights_stay,
                        label: 'Durasi',
                        value: '${reservation.jumlahMalam} malam',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Permintaan Khusus
                  if (reservation.permintaan.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Permintaan Khusus',
                      icon: Icons.notes_outlined,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            reservation.permintaan,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Timestamp
                  _SectionCard(
                    title: 'Informasi Sistem',
                    icon: Icons.info_outline,
                    children: [
                      InfoRow(
                        icon: Icons.calendar_today,
                        label: 'Dibuat',
                        value: _formatDateTime(reservation.createdAt),
                      ),
                      InfoRow(
                        icon: Icons.update,
                        label: 'Diperbarui',
                        value: _formatDateTime(reservation.updatedAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Reservation reservation,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Reservasi'),
        content: Text(
          'Yakin ingin menghapus reservasi a.n "${reservation.namaTamu}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final result = await context
          .read<ReservationProvider>()
          .deleteReservation(reservation.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? ''),
            backgroundColor: result['success'] == true
                ? AppTheme.success
                : AppTheme.error,
          ),
        );
        if (result['success'] == true) {
          Navigator.popUntil(context, ModalRoute.withName('/reservations'));
        }
      }
    }
  }
}

// ─── Section Card ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.divider),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.accent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
