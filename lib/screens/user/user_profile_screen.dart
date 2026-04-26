// lib/screens/user/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/app_constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final res  = context.watch<ReservationProvider>();
    final user = auth.user;

    final myRes     = res.allReservations;
    final myTotal   = myRes.length;
    final myActive  = myRes.where((r) =>
        r.status == 'Booking' || r.status == 'Dikonfirmasi' ||
        r.status == 'Check-In').length;
    final mySpend   = myRes.fold(0, (s, r) => s + r.totalHarga);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark])),
                child: SafeArea(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76, height: 76,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accent, width: 2.5),
                      ),
                      child: Center(child: Text(
                        (user?.username.isNotEmpty ?? false)
                            ? user!.username[0].toUpperCase() : 'S',
                        style: const TextStyle(color: AppTheme.accent,
                            fontSize: 30, fontWeight: FontWeight.bold),
                      )),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 10),
                    Text(user?.username ?? '—',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20, fontWeight: FontWeight.bold))
                        .animate(delay: 100.ms).fadeIn(),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '—',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.65), fontSize: 13))
                        .animate(delay: 150.ms).fadeIn(),
                    const SizedBox(height: 8),
                    const RoleBadge(isAdmin: false)
                        .animate(delay: 200.ms).fadeIn(),
                  ],
                )),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Personal stats — NOT global stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                      blurRadius: 8)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Statistik Saya',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _Stat('Total Reservasi',
                        myTotal.toString(), AppTheme.primary)),
                    Expanded(child: _Stat('Aktif',
                        myActive.toString(), AppTheme.checkInC)),
                  ]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppTheme.accentLight,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.monetization_on,
                          color: AppTheme.accent, size: 20),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Total Pengeluaran Saya',
                            style: TextStyle(fontSize: 11,
                                color: AppTheme.textSec)),
                        Text(formatRupiah(mySpend),
                            style: const TextStyle(fontWeight: FontWeight.bold,
                                color: AppTheme.primary, fontSize: 14)),
                      ]),
                    ]),
                  ),
                ]),
              ).animate().fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Info hak akses pelanggan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.verified_user_outlined,
                          size: 16, color: AppTheme.accent),
                      SizedBox(width: 8),
                      Text('Hak Akses Anda',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textPri)),
                    ]),
                    const SizedBox(height: 12),
                    _AccessRow(
                        icon: Icons.check_circle,
                        color: AppTheme.checkInC,
                        text: 'Buat reservasi baru'),
                    _AccessRow(
                        icon: Icons.check_circle,
                        color: AppTheme.checkInC,
                        text: 'Lihat daftar reservasi Anda'),
                    _AccessRow(
                        icon: Icons.check_circle,
                        color: AppTheme.checkInC,
                        text: 'Ubah jadwal (reschedule) reservasi berstatus Booking'),
                    _AccessRow(
                        icon: Icons.cancel,
                        color: AppTheme.textSec,
                        text: 'Ubah data tamu / jenis kamar — hanya admin hotel'),
                    _AccessRow(
                        icon: Icons.cancel,
                        color: AppTheme.textSec,
                        text: 'Hapus reservasi — hanya admin hotel'),
                    _AccessRow(
                        icon: Icons.cancel,
                        color: AppTheme.textSec,
                        text: 'Ubah status reservasi — hanya admin hotel'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppTheme.accentLight,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Row(children: [
                        Icon(Icons.support_agent,
                            size: 15, color: AppTheme.accent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Untuk perubahan data lainnya, hubungi petugas hotel kami.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.accent,
                                height: 1.4),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Menu
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                      blurRadius: 8)],
                ),
                child: Column(children: [
                  _MenuItem(Icons.hotel_outlined, 'Reservasi Saya',
                      () => {}),
                  const Divider(height: 1, indent: 56),
                  _MenuItem(Icons.add_circle_outline, 'Buat Reservasi Baru',
                      () => Navigator.pushNamed(context, '/reservations/add')),
                  const Divider(height: 1, indent: 56),
                  _MenuItem(Icons.info_outline, 'Tentang Aplikasi',
                      () => _about(context)),
                ]),
              ),              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error)),
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                ),
              ),
              const SizedBox(height: 20),
              const Center(child: Text('v1.0.0 · Grand Mugarsari Hotel',
                  style: TextStyle(color: AppTheme.textSec, fontSize: 11))),
              const SizedBox(height: 16),
            ])),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<ReservationProvider>().reset();
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  void _about(BuildContext context) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(children: [
        Icon(Icons.hotel, color: AppTheme.accent),
        SizedBox(width: 8), Text('Grand Mugarsari'),
      ]),
      content: const Text(
        'Hotel Reservation System v1.0.0\n\n'
        'Portal reservasi online untuk pelanggan Grand Mugarsari Hotel.\n\n'
        'Buat reservasi kapan saja — tim hotel kami siap memproses pesanan Anda.',
        style: TextStyle(height: 1.6),
      ),
      actions: [ElevatedButton(
          onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
    ),
  );
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 22,
        fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSec)),
  ]);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppTheme.accentLight,
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: AppTheme.accent, size: 18),
    ),
    title: Text(label, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.arrow_forward_ios,
        size: 13, color: AppTheme.textSec),
    onTap: onTap,
  );
}

class _AccessRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _AccessRow(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                color: color == AppTheme.checkInC
                    ? AppTheme.textPri
                    : AppTheme.textSec,
                height: 1.4)),
      ),
    ]),
  );
}
