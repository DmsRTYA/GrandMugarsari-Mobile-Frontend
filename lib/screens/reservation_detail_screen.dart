// lib/screens/reservation_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/reservation_model.dart';
import '../models/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReservationDetailScreen extends StatelessWidget {
  const ReservationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r       = ModalRoute.of(context)!.settings.arguments as Reservation;
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 165,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark])),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(60, 14, 16, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Reservasi #${r.id}',
                        style: const TextStyle(color: AppTheme.accent,
                            fontSize: 12, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(r.namaTamu, style: const TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    StatusBadge(status: r.status),
                  ]),
                )),
              ),
            ),
            actions: [
              // Admin: tombol edit & hapus penuh
              if (isAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.pushNamed(
                      context, '/reservations/edit', arguments: r),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, r),
                ),
              ]
              // Pelanggan: hanya reschedule jika masih Booking
              else if (r.status == 'Booking')
                IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  tooltip: 'Ubah Jadwal',
                  onPressed: () => Navigator.pushNamed(
                      context, '/reservations/reschedule', arguments: r),
                ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Price banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.monetization_on,
                        color: AppTheme.accent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Total Harga',
                        style: TextStyle(color: Colors.white60, fontSize: 12)),
                    Text(formatRupiah(r.totalHarga),
                        style: const TextStyle(color: AppTheme.accent,
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text('${r.jumlahMalam} malam × '
                        '${r.jumlahKamar} kamar ${r.jenisKamar}',
                        style: const TextStyle(color: Colors.white54,
                            fontSize: 11)),
                  ])),
                ]),
              ).animate().fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 350.ms),

              const SizedBox(height: 14),

              _Card('Informasi Tamu', Icons.person_outline, [
                // Tampilkan akun pelanggan jika tersedia (admin view)
                if (r.namaPelanggan != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E44AD).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF8E44AD).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.hotel_class_outlined,
                          size: 15, color: Color(0xFF8E44AD)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Akun Pelanggan',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF8E44AD),
                                  fontWeight: FontWeight.w600)),
                          Text('@${r.namaPelanggan}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8E44AD))),
                        ],
                      ),
                    ]),
                  ),
                InfoRow(icon: Icons.person, label: 'Nama', value: r.namaTamu),
                InfoRow(icon: Icons.email_outlined, label: 'Email', value: r.email),
                InfoRow(icon: Icons.phone_outlined, label: 'Telepon', value: r.telepon),
                InfoRow(icon: Icons.badge_outlined, label: 'No. Identitas',
                    value: r.noIdentitas),
                InfoRow(icon: Icons.group_outlined, label: 'Jumlah Tamu',
                    value: '${r.jumlahTamu} orang'),
              ], 1),

              const SizedBox(height: 12),

              _Card('Detail Kamar', Icons.hotel_outlined, [
                InfoRow(icon: Icons.bed, label: 'Jenis Kamar', value: r.jenisKamar),
                InfoRow(icon: Icons.door_front_door_outlined, label: 'Jumlah Kamar',
                    value: '${r.jumlahKamar} kamar'),
                InfoRow(icon: Icons.login, label: 'Check-In',
                    value: formatDateLong(r.checkIn)),
                InfoRow(icon: Icons.logout, label: 'Check-Out',
                    value: formatDateLong(r.checkOut)),
                InfoRow(icon: Icons.nights_stay, label: 'Durasi',
                    value: '${r.jumlahMalam} malam'),
              ], 2),

              if (r.permintaan.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Card('Permintaan Khusus', Icons.notes_outlined, [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(r.permintaan,
                        style: const TextStyle(color: AppTheme.textSec,
                            height: 1.5, fontSize: 14)),
                  ),
                ], 3),
              ],

              const SizedBox(height: 12),

              _Card('Info Sistem', Icons.info_outline, [
                InfoRow(icon: Icons.calendar_today, label: 'Dibuat',
                    value: formatDateTime(r.createdAt)),
                InfoRow(icon: Icons.update, label: 'Diperbarui',
                    value: formatDateTime(r.updatedAt)),
              ], 4),

              const SizedBox(height: 32),
            ])),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext ctx, Reservation r) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus Reservasi'),
        content: Text('Hapus reservasi a.n "${r.namaTamu}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && ctx.mounted) {
      final res = await ctx.read<ReservationProvider>().delete(r.id);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(res['message'] as String? ?? ''),
          backgroundColor:
              res['success'] == true ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ));
        if (res['success'] == true) Navigator.pop(ctx);
      }
    }
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final int index;
  const _Card(this.title, this.icon, this.children, this.index);

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.divider))),
        child: Row(children: [
          Icon(icon, size: 17, color: AppTheme.accent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 14, color: AppTheme.textPri)),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16),
          child: Column(children: children)),
    ]),
  ).animate(delay: Duration(milliseconds: 80 * index))
      .fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0, duration: 350.ms);
}
