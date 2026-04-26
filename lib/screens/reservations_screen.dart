// lib/screens/reservations_screen.dart
// Daftar reservasi: filter status, pencarian, CRUD actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservation_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/reservation_card.dart';
import '../models/app_constants.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().loadReservations();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Reservasi'),
        content: Text(
          'Yakin ingin menghapus reservasi a.n "$name"?',
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
    if (confirm == true && mounted) {
      final res = context.read<ReservationProvider>();
      final result = await res.deleteReservation(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? ''),
            backgroundColor: result['success'] == true
                ? AppTheme.success
                : AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Data Reservasi'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/reservations/add'),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tambah Reservasi',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────────────
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => res.setSearch(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama, email, jenis kamar...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withOpacity(0.7)),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.white.withOpacity(0.7)),
                        onPressed: () {
                          _searchCtrl.clear();
                          res.setSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // ── Filter Chips ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isActive: res.activeFilter == 'all',
                    onTap: () => res.setFilter('all'),
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  ...kStatusOptions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: s,
                        isActive: res.activeFilter == s,
                        onTap: () => res.setFilter(s),
                        color: AppTheme.statusColor(s),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: res.state == ReservationState.loading
                ? const LoadingWidget(message: 'Memuat data reservasi...')
                : res.state == ReservationState.error
                    ? ErrorWidget2(
                        message: res.errorMessage ?? 'Gagal memuat data',
                        onRetry: () => res.loadReservations(),
                      )
                    : res.reservations.isEmpty
                        ? EmptyWidget(
                            icon: Icons.search_off,
                            title: 'Tidak Ada Data',
                            subtitle: res.searchQuery.isNotEmpty
                                ? 'Tidak ditemukan hasil untuk "${res.searchQuery}"'
                                : 'Belum ada reservasi dengan status ini',
                          )
                        : RefreshIndicator(
                            onRefresh: () => res.loadReservations(),
                            color: AppTheme.accent,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: res.reservations.length,
                              itemBuilder: (_, i) {
                                final r = res.reservations[i];
                                return ReservationCard(
                                  reservation: r,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/reservations/detail',
                                    arguments: r,
                                  ),
                                  onEdit: () => Navigator.pushNamed(
                                    context,
                                    '/reservations/edit',
                                    arguments: r,
                                  ),
                                  onDelete: () =>
                                      _confirmDelete(r.id, r.namaTamu),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
