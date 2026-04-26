// lib/screens/admin/admin_reschedule_screen.dart
// Admin: lihat & proses permintaan reschedule pelanggan

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/reschedule_request_model.dart';
import '../../models/app_constants.dart';
import '../../providers/reschedule_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminRescheduleScreen extends StatefulWidget {
  const AdminRescheduleScreen({super.key});
  @override State<AdminRescheduleScreen> createState() =>
      _AdminRescheduleScreenState();
}

class _AdminRescheduleScreenState extends State<AdminRescheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RescheduleProvider>().load();
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<RescheduleRequest> _filter(
      List<RescheduleRequest> all, String status) =>
      all.where((r) => r.status == status).toList();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RescheduleProvider>();

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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(children: [
                const Expanded(
                  child: Text('Permintaan Reschedule',
                      style: TextStyle(color: Colors.white, fontSize: 19,
                          fontWeight: FontWeight.bold)),
                ),
                if (prov.pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('${prov.pendingCount} pending',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => prov.load(),
                ),
              ]),
            ),
            TabBar(
              controller: _tab,
              indicatorColor: AppTheme.accent,
              labelColor: AppTheme.accent,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: 'Menunggu (${prov.requests.where((r) => r.isPending).length})'),
                Tab(text: 'Disetujui'),
                Tab(text: 'Ditolak'),
              ],
            ),
          ])),
        ),

        // Content
        Expanded(child: prov.isLoading
            ? const LoadingWidget(message: 'Memuat permintaan...')
            : prov.state == RescheduleState.error
                ? AppErrorWidget(
                    message: prov.error ?? 'Gagal', onRetry: prov.load)
                : TabBarView(
                    controller: _tab,
                    children: [
                      _RequestList(
                        requests: _filter(prov.requests, 'pending'),
                        isActionable: true,
                        emptyTitle: 'Tidak Ada Permintaan',
                        emptySubtitle: 'Semua permintaan reschedule\nsudah diproses.',
                        onProcess: _processRequest,
                      ),
                      _RequestList(
                        requests: _filter(prov.requests, 'approved'),
                        isActionable: false,
                        emptyTitle: 'Belum Ada',
                        emptySubtitle: 'Belum ada reschedule yang disetujui.',
                        onProcess: _processRequest,
                      ),
                      _RequestList(
                        requests: _filter(prov.requests, 'rejected'),
                        isActionable: false,
                        emptyTitle: 'Belum Ada',
                        emptySubtitle: 'Belum ada reschedule yang ditolak.',
                        onProcess: _processRequest,
                      ),
                    ],
                  )),
      ]),
    );
  }

  Future<void> _processRequest(
      RescheduleRequest req, String action) async {
    final catatanCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: Text(action == 'approved'
            ? '✅  Setujui Reschedule'
            : '❌  Tolak Reschedule'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _InfoLine('Tamu', req.namaTamu ?? '—'),
          _InfoLine('Pelanggan', '@${req.namaPelanggan ?? '—'}'),
          _InfoLine('Kamar', req.jenisKamar ?? '—'),
          _InfoLine('Jadwal Lama', req.formattedOldDates),
          _InfoLine('Jadwal Baru', req.formattedNewDates),
          if (req.alasan.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoLine('Alasan', req.alasan),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: catatanCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Catatan untuk pelanggan (opsional)',
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.divider)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approved'
                  ? AppTheme.success : AppTheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action == 'approved' ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await context.read<RescheduleProvider>().process(
      requestId:    req.id,
      action:       action,
      catatanAdmin: catatanCtrl.text.trim(),
    );

    // Reload reservations jika disetujui agar dashboard sinkron
    if (result['success'] == true && action == 'approved' && mounted) {
      context.read<ReservationProvider>().load();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['message'] as String? ?? ''),
      backgroundColor:
          result['success'] == true ? AppTheme.success : AppTheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

// ── Request List ──────────────────────────────────────────────────────────────
class _RequestList extends StatelessWidget {
  final List<RescheduleRequest> requests;
  final bool isActionable;
  final String emptyTitle, emptySubtitle;
  final Future<void> Function(RescheduleRequest, String) onProcess;

  const _RequestList({
    required this.requests,
    required this.isActionable,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onProcess,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return EmptyWidget(
          icon: Icons.event_available_outlined,
          title: emptyTitle,
          subtitle: emptySubtitle);
    }
    return RefreshIndicator(
      onRefresh: () => context.read<RescheduleProvider>().load(),
      color: AppTheme.accent,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: requests.length,
        itemBuilder: (_, i) => _RequestCard(
          request: requests[i],
          index: i,
          isActionable: isActionable,
          onApprove: isActionable
              ? () => onProcess(requests[i], 'approved')
              : null,
          onReject: isActionable
              ? () => onProcess(requests[i], 'rejected')
              : null,
        ),
      ),
    );
  }
}

// ── Request Card ─────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final RescheduleRequest request;
  final int index;
  final bool isActionable;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _RequestCard({
    required this.request,
    required this.index,
    required this.isActionable,
    this.onApprove,
    this.onReject,
  });

  Color get _statusColor {
    switch (request.status) {
      case 'pending':  return AppTheme.booking;
      case 'approved': return AppTheme.checkInC;
      case 'rejected': return AppTheme.error;
      default:         return AppTheme.textSec;
    }
  }

  Color get _statusBg {
    switch (request.status) {
      case 'pending':  return const Color(0xFFFDF8ED);
      case 'approved': return const Color(0xFFEAFAF1);
      case 'rejected': return const Color(0xFFFDECEB);
      default:         return AppTheme.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, 4))],
        border: Border(
          left: BorderSide(color: _statusColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Pelanggan & tamu
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFF8E44AD).withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.person_pin,
                  color: Color(0xFF8E44AD), size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (request.namaPelanggan != null)
                Text('@${request.namaPelanggan}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E44AD),
                        fontWeight: FontWeight.w600)),
              Text(request.namaTamu ?? '—',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, color: AppTheme.textPri)),
            ])),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _statusColor.withOpacity(0.4)),
              ),
              child: Text(request.statusLabel,
                  style: TextStyle(color: _statusColor,
                      fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),

          const Divider(height: 20),

          // Detail kamar
          if (request.jenisKamar != null)
            Row(children: [
              const Icon(Icons.hotel, size: 13, color: AppTheme.textSec),
              const SizedBox(width: 5),
              Text('${request.jenisKamar} · ${request.jumlahKamar ?? 1} kamar',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSec)),
            ]),
          const SizedBox(height: 8),

          // Jadwal lama → baru
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.calendar_today,
                    size: 12, color: AppTheme.textSec),
                const SizedBox(width: 6),
                const Text('Jadwal saat ini:',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSec)),
                const SizedBox(width: 6),
                Text(request.formattedOldDates,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppTheme.textSec)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.edit_calendar,
                    size: 12, color: AppTheme.dikonfirmasi),
                const SizedBox(width: 6),
                const Text('Jadwal baru:',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.dikonfirmasi)),
                const SizedBox(width: 6),
                Text(request.formattedNewDates,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold,
                        color: AppTheme.dikonfirmasi)),
              ]),
            ]),
          ),

          // Alasan
          if (request.alasan.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.message_outlined,
                  size: 12, color: AppTheme.textSec),
              const SizedBox(width: 5),
              Expanded(child: Text('Alasan: ${request.alasan}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSec,
                      height: 1.4))),
            ]),
          ],

          // Catatan admin (jika sudah diproses)
          if (request.catatanAdmin.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: _statusBg, borderRadius: BorderRadius.circular(8)),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.admin_panel_settings,
                    size: 12, color: _statusColor),
                const SizedBox(width: 5),
                Expanded(child: Text(
                    'Catatan admin: ${request.catatanAdmin}',
                    style: TextStyle(
                        fontSize: 12, color: _statusColor,
                        height: 1.4))),
              ]),
            ),
          ],

          // Waktu pengajuan
          const SizedBox(height: 8),
          Text('Diajukan: ${formatDateTime(request.createdAt)}',
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSec)),

          // Action buttons (hanya untuk pending)
          if (isActionable) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 10)),
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Tolak',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 10)),
                  onPressed: onApprove,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Setujui',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ]),
          ],
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0, duration: 350.ms,
            curve: Curves.easeOut);
  }
}

class _InfoLine extends StatelessWidget {
  final String label, value;
  const _InfoLine(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 90,
        child: Text('$label:', style: const TextStyle(
            fontSize: 12, color: AppTheme.textSec)),
      ),
      Expanded(child: Text(value,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppTheme.textPri))),
    ]),
  );
}
