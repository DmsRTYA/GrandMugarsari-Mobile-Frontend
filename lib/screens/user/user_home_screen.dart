// lib/screens/user/user_home_screen.dart
// Beranda user biasa — hanya statistik milik user sendiri

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/app_constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/reservation_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});
  @override State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final res  = context.watch<ReservationProvider>();

    // Stats only for current user's reservations
    final myRes = res.allReservations;
    final myTotal   = myRes.length;
    final myActive  = myRes.where((r) =>
        r.status == 'Booking' || r.status == 'Dikonfirmasi' ||
        r.status == 'Check-In').length;
    final myPending = myRes.where((r) => r.status == 'Booking').length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: RefreshIndicator(
        onRefresh: () => context.read<ReservationProvider>().load(),
        color: AppTheme.accent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 195,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppTheme.primary, AppTheme.primaryDark])),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.hotel,
                                color: AppTheme.accent, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(child: Text('Grand Mugarsari',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 15, fontWeight: FontWeight.bold))),
                          RoleBadge(isAdmin: false),
                        ]),
                        const SizedBox(height: 16),
                        Text('Halo,',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13)),
                        Text(auth.user?.username ?? 'Tamu',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text('Selamat datang di portal reservasi Anda',
                            style: TextStyle(color: AppTheme.accent,
                                fontSize: 11, letterSpacing: 0.3)),
                      ]),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/reservations/add'),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // Personal stats
                if (res.state == ResState.loaded) ...[
                  _buildPersonalStats(myTotal, myActive, myPending),
                  const SizedBox(height: 20),
                ],

                // Quick Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/reservations/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Reservasi Baru'),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                SectionHeader(
                  title: 'Reservasi Terbaru Saya',
                  trailing: res.allReservations.isNotEmpty ? 'Lihat Semua' : null,
                  onTrailingTap: () {},
                ),
                const SizedBox(height: 12),

                // Three-state
                if (res.state == ResState.loading)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 32),
                      child: LoadingWidget(message: 'Memuat...'))
                else if (res.state == ResState.error)
                  AppErrorWidget(
                      message: res.errorMessage ?? 'Gagal', onRetry: res.load)
                else if (myRes.isEmpty)
                  EmptyWidget(
                    icon: Icons.hotel_outlined,
                    title: 'Belum Ada Reservasi',
                    subtitle: 'Buat reservasi pertama Anda sekarang',
                    onAction: () =>
                        Navigator.pushNamed(context, '/reservations/add'),
                    actionLabel: 'Buat Sekarang',
                  )
                else
                  ...myRes.take(3).toList().asMap().entries.map((e) =>
                    ReservationCard(
                      reservation: e.value, index: e.key,
                      onTap: () => Navigator.pushNamed(
                          context, '/reservations/detail',
                          arguments: e.value),
                    ),
                  ),

                const SizedBox(height: 24),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalStats(int total, int active, int pending) {
    return Row(children: [
      Expanded(child: _PersonalStatCard(
          'Total Booking', total.toString(),
          Icons.receipt_long, AppTheme.primary, 0)),
      const SizedBox(width: 10),
      Expanded(child: _PersonalStatCard(
          'Aktif', active.toString(),
          Icons.check_circle_outline, AppTheme.checkInC, 1)),
      const SizedBox(width: 10),
      Expanded(child: _PersonalStatCard(
          'Menunggu', pending.toString(),
          Icons.pending_outlined, AppTheme.booking, 2)),
    ]);
  }
}

class _PersonalStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final int index;
  const _PersonalStatCard(this.label, this.value, this.icon, this.color, this.index);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(
          fontSize: 10, color: AppTheme.textSec),
          textAlign: TextAlign.center),
    ]),
  ).animate(delay: Duration(milliseconds: 80 * index))
      .fadeIn(duration: 350.ms).slideY(begin: 0.15, end: 0, duration: 350.ms);
}
