// lib/screens/admin/admin_reservations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/app_constants.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/reservation_card.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});
  @override State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
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
            child: const Text('Hapus'),
          ),
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
        // ── Header ─────────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark])),
          child: SafeArea(
            bottom: false,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  const Text('Data Reservasi',
                      style: TextStyle(color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (res.state == ResState.loaded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                      child: Text('${res.allReservations.length} data',
                          style: const TextStyle(color: AppTheme.accent,
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/reservations/add'),
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    tooltip: 'Tambah',
                  ),
                ]),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: res.setSearch,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, jenis kamar...',
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
            ]),
          ),
        ),

        // ── Filter Chips ────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              _FilterChip('Semua', res.activeFilter == 'all',
                  () => res.setFilter('all'), AppTheme.primary),
              ...kStatusOptions.map((s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _FilterChip(s, res.activeFilter == s,
                    () => res.setFilter(s), AppTheme.statusColor(s)),
              )),
            ]),
          ),
        ),
        const Divider(height: 1),

        // ── List ────────────────────────────────────────────────────
        Expanded(child: _buildList(res)),
      ]),
    );
  }

  Widget _buildList(ReservationProvider res) {
    if (res.state == ResState.loading) {
      return const LoadingWidget(message: 'Memuat data...');
    }
    if (res.state == ResState.error) {
      return AppErrorWidget(
          message: res.errorMessage ?? 'Gagal', onRetry: res.load);
    }
    if (res.reservations.isEmpty) {
      return EmptyWidget(
        icon: Icons.search_off,
        title: 'Tidak Ada Data',
        subtitle: res.searchQuery.isNotEmpty
            ? 'Tidak ditemukan hasil untuk "${res.searchQuery}"'
            : 'Belum ada reservasi dengan status ini',
      );
    }
    return RefreshIndicator(
      onRefresh: res.load,
      color: AppTheme.accent,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;
  const _FilterChip(this.label, this.active, this.onTap, this.color);

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
