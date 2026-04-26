// lib/screens/user/user_home_screen.dart
// Beranda user biasa — hanya statistik milik user sendiri

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/reschedule_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RescheduleProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final res  = context.watch<ReservationProvider>();
    final rp   = context.watch<RescheduleProvider>();

    // Stats only for current user's reservations
    final myRes = res.allReservations;
    final myTotal   = myRes.length;
    final myActive  = myRes.where((r) =>
        r.status == 'Booking' || r.status == 'Dikonfirmasi' ||
        r.status == 'Check-In').length;
    final myPending = myRes.where((r) => r.status == 'Booking').length;
    final myConfirmed = myRes.where((r) => r.status == 'Dikonfirmasi').length;

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
                          RoleBadge(isAdmin: false),                        ]),
                        const SizedBox(height: 16),
                          const Text('Halo,',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                          Text(auth.user?.username ?? 'Pelanggan',
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
                  _buildPersonalStats(myTotal, myActive, myConfirmed),
                  const SizedBox(height: 14),
                ],

                // Banner status reschedule
                if (rp.state == RescheduleState.loaded &&
                    rp.requests.isNotEmpty) ...[
                  _RescheduleStatusBanner(requests: rp.requests),
                  const SizedBox(height: 14),
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
                    subtitle: 'Buat reservasi pertama Anda sekarang.\nBooking Anda akan masuk ke hotel secara otomatis.',
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

// ── Reschedule Status Banner ─────────────────────────────────────────────────
class _RescheduleStatusBanner extends StatelessWidget {
  final List requests;
  const _RescheduleStatusBanner({required this.requests});

  @override
  Widget build(BuildContext context) {
    // Tampilkan hanya request terbaru yang masih pending atau baru diproses
    final recent = requests.take(3).toList();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Status Reschedule'),
        const SizedBox(height: 8),
        ...recent.asMap().entries.map((e) {
          final r = e.value;
          final status = r.status as String;
          Color color;
          IconData icon;
          String label;
          switch (status) {
            case 'pending':
              color = AppTheme.booking;
              icon  = Icons.pending_actions;
              label = 'Menunggu persetujuan admin';
              break;
            case 'approved':
              color = AppTheme.checkInC;
              icon  = Icons.check_circle_outline;
              label = 'Disetujui — jadwal telah diperbarui';
              break;
            default:
              color = AppTheme.error;
              icon  = Icons.cancel_outlined;
              label = 'Ditolak oleh admin';
          }
          final oldDates =
              '${formatDate(r.oldCheckIn as String)} → ${formatDate(r.oldCheckOut as String)}';
          final newDates =
              '${formatDate(r.newCheckIn as String)} → ${formatDate(r.newCheckOut as String)}';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(
                        color: color, fontWeight: FontWeight.bold,
                        fontSize: 12)),
                    const SizedBox(height: 3),
                    Text('$oldDates  →  $newDates',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSec)),
                    if ((r.catatanAdmin as String).isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text('Catatan: ${r.catatanAdmin}',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSec,
                              fontStyle: FontStyle.italic)),
                    ],
                  ],
                )),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 60 * e.key))
              .fadeIn(duration: 300.ms);
        }),
      ],
    );
  }
}
