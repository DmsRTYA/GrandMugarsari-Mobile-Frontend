// lib/screens/user/reschedule_screen.dart
// Pelanggan hanya bisa mengubah tanggal check-in dan check-out.
// Data tamu, jenis kamar, dan status TIDAK bisa diubah oleh pelanggan.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/reservation_model.dart';
import '../../models/app_constants.dart';
import '../../providers/reschedule_provider.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/common_widgets.dart';

class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({super.key});
  @override State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  late Reservation _reservation;
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _populated  = false;
  bool _submitting = false;
  final _alasanCtrl = TextEditingController();

  @override
  void dispose() {
    _alasanCtrl.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_populated) return;
    _populated = true;
    _reservation =
        ModalRoute.of(context)!.settings.arguments as Reservation;
    try {
      _checkIn = DateTime.parse(_reservation.checkIn);
      _checkOut = DateTime.parse(_reservation.checkOut);
    } catch (_) {}
  }

  int get _harga => (_checkIn != null && _checkOut != null)
      ? calcHarga(
          _reservation.jenisKamar, _reservation.jumlahKamar,
          _checkIn!, _checkOut!)
      : _reservation.totalHarga;

  bool get _hasChanged {
    if (_checkIn == null || _checkOut == null) return false;
    final origIn  = _reservation.checkIn.split('T').first;
    final origOut = _reservation.checkOut.split('T').first;
    final newIn   = _checkIn!.toIso8601String().split('T').first;
    final newOut  = _checkOut!.toIso8601String().split('T').first;
    return newIn != origIn || newOut != origOut;
  }

  Future<void> _pickDateRange() async {
    DateTime tempFocused = _checkIn ?? DateTime.now();
    DateTime? tempCI = _checkIn;
    DateTime? tempCO = _checkOut;
    bool selectingCI = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.68,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 38, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(children: [
                const Expanded(
                  child: Text('Pilih Jadwal Baru',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPri),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                _DateChip(
                  label: 'Check-In',
                  date: tempCI,
                  isActive: selectingCI,
                  onTap: () =>
                      setModal(() => selectingCI = true),
                ),
                const SizedBox(width: 6),
                _DateChip(
                  label: 'Check-Out',
                  date: tempCO,
                  isActive: !selectingCI,
                  onTap: () =>
                      setModal(() => selectingCI = false),
                ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(DateTime.now().year + 3),
                focusedDay: tempFocused,
                selectedDayPredicate: (d) {
                  if (selectingCI && tempCI != null) {
                    return isSameDay(d, tempCI);
                  }
                  if (!selectingCI && tempCO != null) {
                    return isSameDay(d, tempCO);
                  }
                  return false;
                },
                rangeStartDay: tempCI,
                rangeEndDay: tempCO,
                rangeSelectionMode: RangeSelectionMode.enforced,
                onRangeSelected: (start, end, focused) {
                  setModal(() {
                    tempCI = start;
                    tempCO = end;
                    tempFocused = focused;
                    selectingCI = end == null;
                  });
                },
                onPageChanged: (f) =>
                    setModal(() => tempFocused = f),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.25),
                      shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle),
                  rangeHighlightColor:
                      AppTheme.accent.withOpacity(0.15),
                  rangeStartDecoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  rangeEndDecoration: const BoxDecoration(
                      color: AppTheme.accent, shape: BoxShape.circle),
                  weekendTextStyle:
                      const TextStyle(color: AppTheme.error),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                      color: AppTheme.textPri,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left,
                      color: AppTheme.primary),
                  rightChevronIcon: Icon(Icons.chevron_right,
                      color: AppTheme.primary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                      color: AppTheme.textSec,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                  weekendStyle: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16),
              child: Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                  onPressed: (tempCI != null && tempCO != null)
                      ? () {
                          setState(() {
                            _checkIn = tempCI;
                            _checkOut = tempCO;
                          });
                          Navigator.pop(ctx);
                        }
                      : null,
                  child: const Text('Pilih'),
                )),
              ]),
            ),
          ]),
        );
      }),
    );
  }

  Future<void> _submit() async {
    if (_checkIn == null || _checkOut == null) return;
    if (!_checkOut!.isAfter(_checkIn!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check-out harus setelah check-in'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (!_hasChanged) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tanggal tidak berubah'),
        backgroundColor: AppTheme.textSec,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _submitting = true);

    // Kirim sebagai request, BUKAN langsung update — menunggu persetujuan admin
    final result = await context.read<RescheduleProvider>().submit(
      reservationId: _reservation.id,
      newCheckIn:    _checkIn!.toIso8601String().split('T').first,
      newCheckOut:   _checkOut!.toIso8601String().split('T').first,
      alasan:        _alasanCtrl.text.trim(),
    );

    setState(() => _submitting = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result['message'] as String? ?? ''),
      backgroundColor:
          result['success'] == true ? AppTheme.success : AppTheme.error,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));

    if (result['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final nights = (_checkIn != null && _checkOut != null)
        ? _checkOut!.difference(_checkIn!).inDays
        : _reservation.jumlahMalam;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Ubah Jadwal Reservasi')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // ── Info reservasi (read-only) ──────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05),
                    blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.info_outline,
                      size: 15, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  const Text('Detail Reservasi',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textPri)),
                  const Spacer(),
                  StatusBadge(
                      status: _reservation.status, small: true),
                ]),
                const SizedBox(height: 10),
                InfoRow(
                    icon: Icons.person,
                    label: 'Nama Tamu',
                    value: _reservation.namaTamu),
                InfoRow(
                    icon: Icons.hotel,
                    label: 'Jenis Kamar',
                    value:
                        '${_reservation.jenisKamar} · ${_reservation.jumlahKamar} kamar'),
                InfoRow(
                    icon: Icons.group_outlined,
                    label: 'Jumlah Tamu',
                    value: '${_reservation.jumlahTamu} orang'),
                // Info bahwa data lain hanya bisa diubah admin
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: AppTheme.accent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data tamu & jenis kamar hanya dapat diubah oleh petugas hotel.',
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
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // ── Pilih Jadwal Baru ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05),
                    blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.edit_calendar,
                      size: 15, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  const Text('Jadwal Baru',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textPri)),
                ]),
                const SizedBox(height: 14),

                // Tanggal lama
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(children: [
                    const Icon(Icons.history,
                        size: 14, color: AppTheme.textSec),
                    const SizedBox(width: 8),
                    const Text('Jadwal saat ini: ',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSec)),
                    Text(
                      '${formatDate(_reservation.checkIn)} → ${formatDate(_reservation.checkOut)}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSec),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),

                // Date picker button
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_checkIn != null && _checkOut != null)
                            ? AppTheme.accent
                            : AppTheme.divider,
                        width:
                            (_checkIn != null && _checkOut != null)
                                ? 1.5
                                : 1,
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        Icons.calendar_month,
                        color: _checkIn != null
                            ? AppTheme.accent
                            : AppTheme.textSec,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _checkIn == null
                            ? const Text(
                                'Pilih tanggal check-in & check-out',
                                style: TextStyle(
                                    color: AppTheme.textSec,
                                    fontSize: 13))
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                        child: _DateDisplay(
                                            label: 'Check-In',
                                            date: _checkIn!,
                                            color: AppTheme.primary)),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Icon(Icons.arrow_forward,
                                          size: 14,
                                          color: AppTheme.textSec),
                                    ),
                                    Expanded(
                                        child: _DateDisplay(
                                            label: 'Check-Out',
                                            date: _checkOut,
                                            color: AppTheme.accent)),
                                  ]),
                                  if (_checkIn != null &&
                                      _checkOut != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '$nights malam  ·  ${formatRupiah(_harga)} total',
                                      style: const TextStyle(
                                          color: AppTheme.accent,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      const Icon(Icons.edit_calendar,
                          color: AppTheme.textSec, size: 18),
                    ]),
                  ),
                ),

                // Harga baru jika berubah
                if (_hasChanged) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.calculate_outlined,
                          color: AppTheme.accent, size: 18),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Estimasi harga baru',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 11)),
                        Text(formatRupiah(_harga),
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ]),
                    ]),
                  ).animate().fadeIn(duration: 300.ms).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 300.ms),
                ],
              ],
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // ── Alasan Reschedule ───────────────────────────────────
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
                  Icon(Icons.message_outlined,
                      size: 15, color: AppTheme.accent),
                  SizedBox(width: 6),
                  Text('Alasan Reschedule (opsional)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textPri)),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alasanCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Contoh: Ada keperluan mendadak, ingin geser ke akhir pekan...',
                    hintStyle:
                        TextStyle(fontSize: 12, color: AppTheme.textSec),
                    prefixIcon: Icon(Icons.edit_note),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ).animate(delay: 160.ms).fadeIn(duration: 350.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // ── Info: persetujuan admin ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.booking.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.booking.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.pending_actions,
                    color: AppTheme.booking, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Perlu Persetujuan Admin',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.booking)),
                      const SizedBox(height: 4),
                      Text(
                        'Setelah dikirim, permintaan reschedule Anda akan '
                        'ditinjau oleh petugas hotel. Jadwal hanya akan '
                        'berubah setelah admin menyetujuinya.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.booking.withOpacity(0.85),
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 350.ms),

          const SizedBox(height: 20),

          // ── Tombol kirim ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_hasChanged && !_submitting) ? _submit : null,
              icon: _submitting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white)))
                  : const Icon(Icons.send_outlined),
              label: const Text('Kirim Permintaan Reschedule'),
            ),
          ),

          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Anda akan diberitahu setelah admin memproses permintaan ini.',
              style: TextStyle(fontSize: 11, color: AppTheme.textSec),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────
class _DateChip extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isActive;
  final VoidCallback onTap;
  const _DateChip(
      {required this.label,
      required this.date,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Lebar tetap agar Check-Out tidak overflow ke kanan
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isActive ? AppTheme.primary : AppTheme.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.white70 : AppTheme.textSec)),
              const SizedBox(height: 2),
              Text(
                date != null
                    ? _shortDate(date!)
                    : '—',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppTheme.textPri),
              ),
            ],
          ),
        ),
      );

  // Format ringkas: "29 Apr 2026"
  String _shortDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','Mei','Jun',
                'Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}

class _DateDisplay extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Color color;
  const _DateDisplay(
      {required this.label, required this.date, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSec)),
          Text(
            date != null
                ? formatDate(date!.toIso8601String())
                : '—',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      );
}
