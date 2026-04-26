// lib/screens/user/user_booking_screen.dart
// Pelanggan: lihat daftar reservasi + reschedule tanggal saja.
// Hapus & edit data tamu TIDAK diizinkan — hanya admin yang bisa.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/app_constants.dart';
import '../../models/reservation_model.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({super.key});
  @override State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final res = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark])),
          child: SafeArea(bottom: false, child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(children: [
                const Text('Reservasi Saya',
                    style: TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/reservations/add'),
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.white),
                  tooltip: 'Buat Reservasi Baru',
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: TextField(
                controller: _searchCtrl,
                onChanged: res.setSearch,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari nama tamu, jenis kamar...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.45), fontSize: 13),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withOpacity(0.6), size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close,
                              color: Colors.white.withOpacity(0.6)),
                          onPressed: () {
                            _searchCtrl.clear();
                            res.setSearch('');
                          })
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ])),
        ),

        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              _Chip('Semua', res.activeFilter == 'all',
                  () => res.setFilter('all'), AppTheme.primary),
              ...kStatusOptions.map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _Chip(s, res.activeFilter == s,
                    () => res.setFilter(s), AppTheme.statusColor(s)),
              )),
            ]),
          ),
        ),
        const Divider(height: 1),

        Expanded(child: _buildList(res)),
      ]),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/reservations/add'),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Reservasi',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildList(ReservationProvider res) {
    if (res.state == ResState.loading) {
      return const LoadingWidget(message: 'Memuat reservasi...');
    }
    if (res.state == ResState.error) {
      return AppErrorWidget(
          message: res.errorMessage ?? 'Gagal', onRetry: res.load);
    }
    if (res.reservations.isEmpty) {
      return EmptyWidget(
        icon: Icons.hotel_outlined,
        title: 'Belum Ada Reservasi',
        subtitle: res.searchQuery.isNotEmpty
            ? 'Tidak ditemukan "${res.searchQuery}"'
            : 'Buat reservasi sekarang.\nPetugas hotel akan segera memprosesnya.',
        onAction: () => Navigator.pushNamed(context, '/reservations/add'),
        actionLabel: 'Buat Reservasi',
      );
    }
    return RefreshIndicator(
      onRefresh: res.load,
      color: AppTheme.accent,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        itemCount: res.reservations.length,
        itemBuilder: (_, i) {
          final r = res.reservations[i];
          return _UserReservationCard(
            reservation: r,
            index: i,
            onTap: () => Navigator.pushNamed(
                context, '/reservations/detail', arguments: r),
            onReschedule: r.status == 'Booking'
                ? () => Navigator.pushNamed(
                    context, '/reservations/reschedule', arguments: r)
                : null,
          );
        },
      ),
    );
  }
}

// ── User Reservation Card — no delete, reschedule only for Booking ─────────
class _UserReservationCard extends StatelessWidget {
  final Reservation reservation;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;

  const _UserReservationCard({
    required this.reservation,
    required this.index,
    this.onTap,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final canReschedule = reservation.status == 'Booking';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: Center(
                  child: Text(
                    reservation.namaTamu.isNotEmpty
                        ? reservation.namaTamu[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(reservation.namaTamu,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis),
                  Text(reservation.jenisKamar,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 11)),
                ]),
              ),
              StatusBadge(status: reservation.status, small: true),
            ]),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.calendar_today,
                    size: 13, color: AppTheme.textSec),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    '${formatDate(reservation.checkIn)}  →  ${formatDate(reservation.checkOut)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSec),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.nights_stay,
                    size: 13, color: AppTheme.textSec),
                const SizedBox(width: 4),
                Text(
                  '${reservation.jumlahMalam}m · ${reservation.jumlahKamar}k',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSec),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSec)),
                    Text(formatRupiah(reservation.totalHarga),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent)),
                  ]),
                ),
                if (canReschedule && onReschedule != null)
                  GestureDetector(
                    onTap: onReschedule,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.dikonfirmasi.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                AppTheme.dikonfirmasi.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_calendar,
                              size: 14, color: AppTheme.dikonfirmasi),
                          SizedBox(width: 5),
                          Text('Ubah Jadwal',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.dikonfirmasi)),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.textSec.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 12, color: AppTheme.textSec),
                        const SizedBox(width: 4),
                        Text(
                          reservation.status == 'Check-Out'
                              ? 'Selesai'
                              : 'Diproses Hotel',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSec),
                        ),
                      ],
                    ),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 350.ms)
        .slideY(
            begin: 0.15,
            end: 0,
            duration: 350.ms,
            curve: Curves.easeOut);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;
  const _Chip(this.label, this.active, this.onTap, this.color);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? color : color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: active ? color : color.withOpacity(0.3)),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      );
}
