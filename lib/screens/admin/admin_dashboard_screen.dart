// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/app_constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/reservation_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final res  = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: RefreshIndicator(
        onRefresh: () => context.read<ReservationProvider>().load(),
        color: AppTheme.accent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // ── SliverAppBar ────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 190,
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
                            RoleBadge(isAdmin: auth.isAdmin),
                          ]),
                          const SizedBox(height: 16),
                          Text('Selamat datang,',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 13)),
                          Text(auth.user?.username ?? 'Admin',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text('Panel Administrasi Hotel',
                              style: TextStyle(color: AppTheme.accent,
                                  fontSize: 12, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(
                      context, '/reservations/add'),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  tooltip: 'Tambah Reservasi',
                ),
              ],
            ),

            // ── Body ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // Stats
                if (res.state == ResState.loaded) ...[
                  _buildStatsGrid(res),
                  const SizedBox(height: 20),
                ] else if (res.state == ResState.loading) ...[
                  const SizedBox(height: 20,
                      child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppTheme.accent),
                          backgroundColor: AppTheme.accentLight)),
                  const SizedBox(height: 20),
                ],

                // Quick Add
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/reservations/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Reservasi Baru'),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                SectionHeader(
                  title: 'Reservasi Terbaru',
                  trailing: 'Lihat Semua',
                  onTrailingTap: () => context
                      .findAncestorStateOfType<State>()
                      ?.setState(() {}), // handled by shell index
                ),
                const SizedBox(height: 12),

                // Three-state
                if (res.state == ResState.loading)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 32),
                      child: LoadingWidget(message: 'Memuat reservasi...'))
                else if (res.state == ResState.error)
                  AppErrorWidget(message: res.errorMessage ?? 'Gagal memuat',
                      onRetry: () => res.load())
                else if (res.allReservations.isEmpty)
                  EmptyWidget(
                    icon: Icons.hotel_outlined,
                    title: 'Belum Ada Reservasi',
                    subtitle: 'Tambahkan reservasi pertama',
                    onAction: () =>
                        Navigator.pushNamed(context, '/reservations/add'),
                    actionLabel: 'Tambah',
                  )
                else
                  ...res.allReservations.take(5).toList().asMap().entries.map(
                    (e) => ReservationCard(
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

  Widget _buildStatsGrid(ReservationProvider r) {
    return Column(children: [
      Row(children: [
        Expanded(child: _StatCard('Total', r.total.toString(),
            Icons.receipt_long, AppTheme.primary, 0)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard('Booking', r.booking.toString(),
            Icons.bookmark_outlined, AppTheme.booking, 1)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _StatCard('Check-In', r.checkIn.toString(),
            Icons.login, AppTheme.checkInC, 2)),
        const SizedBox(width: 10),
        Expanded(child: _StatCard('Check-Out', r.checkOut.toString(),
            Icons.logout, AppTheme.checkOutC, 3)),
      ]),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Pendapatan',
                style: TextStyle(color: Colors.white60, fontSize: 12)),
            Text(formatRupiah(r.pendapatan),
                style: const TextStyle(color: AppTheme.accent,
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ).animate(delay: 200.ms).fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, duration: 350.ms),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final int index;
  const _StatCard(this.label, this.value, this.icon, this.color, this.index);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 22,
            fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSec)),
      ]),
    ]),
  ).animate(delay: Duration(milliseconds: 80 * index))
      .fadeIn(duration: 350.ms).slideY(begin: 0.15, end: 0, duration: 350.ms);
}
