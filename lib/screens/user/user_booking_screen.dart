// lib/screens/user/user_booking_screen.dart
// User hanya bisa lihat, tambah, edit, hapus reservasi MILIKNYA sendiri

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/app_constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/reservation_card.dart';

class UserBookingScreen extends StatefulWidget {
  const UserBookingScreen({super.key});
  @override State<UserBookingScreen> createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _confirmDelete(int id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus Reservasi'),
        content: Text('Hapus reservasi a.n "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true && mounted) {
      final r = await context.read<ReservationProvider>().delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(r['message'] as String? ?? ''),
          backgroundColor:
              r['success'] == true ? AppTheme.success : AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark])),
          child: SafeArea(bottom: false, child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(children: [
                const Text('Booking Saya',
                    style: TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/reservations/add'),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  tooltip: 'Buat Booking Baru',
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
                  hintText: 'Cari nama, jenis kamar...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.45), fontSize: 13),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withOpacity(0.6), size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close,
                              color: Colors.white.withOpacity(0.6)),
                          onPressed: () {
                            _searchCtrl.clear(); res.setSearch('');
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

        // Filter chips — only Booking-friendly statuses
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

        // List
        Expanded(child: _buildList(res)),
      ]),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/reservations/add'),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Booking',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildList(ReservationProvider res) {
    if (res.state == ResState.loading) {
      return const LoadingWidget(message: 'Memuat booking...');
    }
    if (res.state == ResState.error) {
      return AppErrorWidget(message: res.errorMessage ?? 'Gagal',
          onRetry: res.load);
    }
    if (res.reservations.isEmpty) {
      return EmptyWidget(
        icon: Icons.hotel_outlined,
        title: 'Belum Ada Booking',
        subtitle: res.searchQuery.isNotEmpty
            ? 'Tidak ditemukan "${res.searchQuery}"'
            : 'Buat reservasi pertama Anda',
        onAction: () => Navigator.pushNamed(context, '/reservations/add'),
        actionLabel: 'Buat Sekarang',
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
          return ReservationCard(
            reservation: r, index: i,
            onTap: () => Navigator.pushNamed(
                context, '/reservations/detail', arguments: r),
            onEdit: () => Navigator.pushNamed(
                context, '/reservations/edit', arguments: r),
            onDelete: () => _confirmDelete(r.id, r.namaTamu),
          );
        },
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? color : color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color : color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(
          color: active ? Colors.white : color,
          fontSize: 13, fontWeight: FontWeight.w600)),
    ),
  );
}
