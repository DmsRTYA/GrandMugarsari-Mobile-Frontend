// lib/screens/reservation_form_screen.dart
// Form tambah/edit — date picker menggunakan TableCalendar Google Material

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/reservation_model.dart';
import '../models/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../widgets/app_theme.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});
  @override State<ReservationFormScreen> createState() =>
      _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _form          = GlobalKey<FormState>();
  final _namaTamuCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _teleponCtrl   = TextEditingController();
  final _idCtrl        = TextEditingController();
  final _noteCtrl      = TextEditingController();

  String   _jenisKamar = kRoomTypes.keys.first;
  int      _jumlahKamar = 1;
  int      _jumlahTamu  = 1;
  // Status hanya bisa diubah oleh admin; pelanggan selalu mulai dengan 'Booking'
  String   _status     = kStatusOptions.first;
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool     _isEdit     = false;
  int?     _editId;
  bool     _submitting = false;
  bool     _populated  = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_populated) return;
    _populated = true;
    final ex = ModalRoute.of(context)?.settings.arguments as Reservation?;
    if (ex != null) {
      _isEdit        = true;
      _editId        = ex.id;
      _namaTamuCtrl.text = ex.namaTamu;
      _emailCtrl.text    = ex.email;
      _teleponCtrl.text  = ex.telepon;
      _idCtrl.text       = ex.noIdentitas;
      _noteCtrl.text     = ex.permintaan;
      _jenisKamar   = ex.jenisKamar;
      _jumlahKamar  = ex.jumlahKamar;
      _jumlahTamu   = ex.jumlahTamu;
      _status       = ex.status;
      try {
        _checkIn  = DateTime.parse(ex.checkIn);
        _checkOut = DateTime.parse(ex.checkOut);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _namaTamuCtrl.dispose(); _emailCtrl.dispose();
    _teleponCtrl.dispose(); _idCtrl.dispose(); _noteCtrl.dispose();
    super.dispose();
  }

  int get _harga {
    if (_checkIn == null || _checkOut == null) return 0;
    return calcHarga(_jenisKamar, _jumlahKamar, _checkIn!, _checkOut!);
  }

  // ── Google-Material calendar bottom sheet ─────────────────────────────────
  Future<void> _pickDateRange() async {
    DateTime tempFocused = _checkIn ?? DateTime.now();
    DateTime? tempCheckIn  = _checkIn;
    DateTime? tempCheckOut = _checkOut;
    bool selectingCheckIn  = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModal) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.68,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 38, height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(children: [
                const Text('Pilih Tanggal',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                        color: AppTheme.textPri)),
                const Spacer(),
                // Check-in chip
                _DateChip(
                  label: 'Check-In',
                  date: tempCheckIn,
                  isActive: selectingCheckIn,
                  onTap: () => setModal(() => selectingCheckIn = true),
                ),
                const SizedBox(width: 8),
                // Check-out chip
                _DateChip(
                  label: 'Check-Out',
                  date: tempCheckOut,
                  isActive: !selectingCheckIn,
                  onTap: () => setModal(() => selectingCheckIn = false),
                ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 1)),
                lastDay: DateTime(DateTime.now().year + 3),
                focusedDay: tempFocused,
                selectedDayPredicate: (d) {
                  if (selectingCheckIn && tempCheckIn != null) {
                    return isSameDay(d, tempCheckIn);
                  }
                  if (!selectingCheckIn && tempCheckOut != null) {
                    return isSameDay(d, tempCheckOut);
                  }
                  return false;
                },
                rangeStartDay: tempCheckIn,
                rangeEndDay: tempCheckOut,
                rangeSelectionMode: RangeSelectionMode.enforced,
                onRangeSelected: (start, end, focused) {
                  setModal(() {
                    tempCheckIn  = start;
                    tempCheckOut = end;
                    tempFocused  = focused;
                    selectingCheckIn = end == null;
                  });
                },
                onPageChanged: (f) => setModal(() => tempFocused = f),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.25),
                      shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  rangeHighlightColor: AppTheme.accent.withOpacity(0.15),
                  rangeStartDecoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  rangeEndDecoration: const BoxDecoration(
                      color: AppTheme.accent, shape: BoxShape.circle),
                  withinRangeTextStyle: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w600),
                  weekendTextStyle: const TextStyle(color: AppTheme.error),
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(color: AppTheme.textPri,
                      fontSize: 15, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left,
                      color: AppTheme.primary),
                  rightChevronIcon: Icon(Icons.chevron_right,
                      color: AppTheme.primary),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppTheme.textSec,
                      fontWeight: FontWeight.w600, fontSize: 12),
                  weekendStyle: TextStyle(color: AppTheme.error,
                      fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16,
                  MediaQuery.of(context).viewInsets.bottom + 16),
              child: Row(children: [
                Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Batal'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: (tempCheckIn != null && tempCheckOut != null)
                      ? () {
                          setState(() {
                            _checkIn  = tempCheckIn;
                            _checkOut = tempCheckOut;
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
    if (!_form.currentState!.validate()) return;
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih tanggal check-in dan check-out terlebih dahulu'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (!_checkOut!.isAfter(_checkIn!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check-out harus setelah check-in'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _submitting = true);

    // Pelanggan selalu kirim status 'Booking'; admin bebas memilih
    final isAdmin = context.read<AuthProvider>().isAdmin;
    final finalStatus = isAdmin ? _status : kStatusOptions.first; // 'Booking'

    final data = {
      'nama_tamu':    _namaTamuCtrl.text.trim(),
      'email':        _emailCtrl.text.trim(),
      'telepon':      _teleponCtrl.text.trim(),
      'no_identitas': _idCtrl.text.trim(),
      'jenis_kamar':  _jenisKamar,
      'jumlah_kamar': _jumlahKamar,
      'check_in':     _checkIn!.toIso8601String().split('T').first,
      'check_out':    _checkOut!.toIso8601String().split('T').first,
      'jumlah_tamu':  _jumlahTamu,
      'status':       finalStatus,
      'permintaan':   _noteCtrl.text.trim(),
    };
    final res = context.read<ReservationProvider>();
    final r = _isEdit
        ? await res.update(_editId!, data)
        : await res.create(data);
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r['message'] as String? ?? ''),
      backgroundColor: r['success'] == true ? AppTheme.success : AppTheme.error,
      behavior: SnackBarBehavior.floating,
    ));
    if (r['success'] == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Reservasi' : 'Buat Reservasi Baru'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Harga preview
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _checkIn != null && _checkOut != null
                  ? _PricePreview(harga: _harga, key: ValueKey(_harga))
                  : const SizedBox.shrink(),
            ),

            // ── Data Tamu ──────────────────────────────────────────
            _sectionTitle('Data Tamu', Icons.person_outline, 0),
            const SizedBox(height: 12),

            _field(_namaTamuCtrl, 'Nama Tamu', Icons.person,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Wajib diisi' : null),
            const SizedBox(height: 12),
            _field(_emailCtrl, 'Email Tamu', Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                }),
            const SizedBox(height: 12),
            _field(_teleponCtrl, 'No. Telepon', Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v?.isEmpty ?? true) ? 'Wajib diisi' : null),
            const SizedBox(height: 12),
            _field(_idCtrl, 'No. Identitas (KTP/SIM/Paspor)',
                Icons.badge_outlined,
                validator: (v) => (v?.trim().isEmpty ?? true) ? 'Wajib diisi' : null),
            const SizedBox(height: 10),
            _counter('Jumlah Tamu', _jumlahTamu, 1, 20,
                (v) => setState(() => _jumlahTamu = v)),

            // ── Detail Kamar ───────────────────────────────────────
            const SizedBox(height: 20),
            _sectionTitle('Detail Kamar', Icons.hotel_outlined, 1),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _jenisKamar,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Jenis Kamar',
                prefixIcon: Icon(Icons.bed),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              selectedItemBuilder: (context) => kRoomTypes.entries.map((e) =>
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${e.key}  ·  ${formatRupiah(e.value)}/malam',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textPri),
                  ),
                ),
              ).toList(),
              items: kRoomTypes.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.key,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPri)),
                    Text(
                      '${formatRupiah(e.value)} / malam',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSec),
                    ),
                  ],
                ),
              )).toList(),
              onChanged: (v) => setState(() => _jenisKamar = v!),
            ),
            const SizedBox(height: 12),
            _counter('Jumlah Kamar', _jumlahKamar, 1, 10,
                (v) => setState(() => _jumlahKamar = v)),

            // ── Tanggal (Google Calendar) ──────────────────────────
            const SizedBox(height: 20),
            _sectionTitle('Tanggal Menginap', Icons.calendar_month, 2),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_checkIn != null && _checkOut != null)
                        ? AppTheme.accent : AppTheme.divider,
                    width: (_checkIn != null && _checkOut != null) ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_month,
                      color: _checkIn != null
                          ? AppTheme.accent : AppTheme.textSec, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _checkIn == null
                        ? const Text('Pilih tanggal check-in & check-out',
                            style: TextStyle(color: AppTheme.textSec,
                                fontSize: 13))
                        : Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(children: [
                            Expanded(child: _DateDisplay(
                                label: 'Check-In',
                                date: _checkIn!,
                                color: AppTheme.primary)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.arrow_forward,
                                  size: 14, color: AppTheme.textSec),
                            ),
                            Expanded(child: _DateDisplay(
                                label: 'Check-Out',
                                date: _checkOut,
                                color: AppTheme.accent)),
                          ]),
                          if (_checkIn != null && _checkOut != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${_checkOut!.difference(_checkIn!).inDays} malam  ·  '
                              '${formatRupiah(_harga)} total',
                              style: const TextStyle(color: AppTheme.accent,
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ]),
                  ),
                  const Icon(Icons.edit_calendar, color: AppTheme.textSec,
                      size: 18),
                ]),
              ),
            ),

            // ── Status & Permintaan ────────────────────────────────
            const SizedBox(height: 20),
            _sectionTitle('Info Tambahan', Icons.info_outline, 3),
            const SizedBox(height: 12),

            // Status hanya tampil untuk admin; pelanggan otomatis 'Booking'
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                if (auth.isAdmin) {
                  // Admin: bisa pilih semua status
                  return DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                        labelText: 'Status Reservasi',
                        prefixIcon: Icon(Icons.flag_outlined)),
                    items: kStatusOptions.map((s) => DropdownMenuItem(
                        value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  );
                }
                // Pelanggan: status terkunci di 'Booking', tampilkan info banner
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.checkInC.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.checkInC.withOpacity(0.35)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppTheme.checkInC, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Reservasi Anda akan diproses',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppTheme.textPri)),
                                const SizedBox(height: 3),
                                Text(
                                  'Setelah dikirim, booking Anda langsung masuk '
                                  'ke sistem hotel kami dan akan segera dikonfirmasi '
                                  'oleh petugas.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSec,
                                      height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Status read-only badge
                    Row(children: [
                      const Text('Status awal: ',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textSec)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.statusBg('Booking'),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.booking.withOpacity(0.4)),
                        ),
                        child: const Text('Booking',
                            style: TextStyle(
                                color: AppTheme.booking,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ]),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Permintaan Khusus (opsional)',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              child: Consumer<AuthProvider>(
                builder: (_, auth, __) => ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : Text(
                          _isEdit
                              ? 'Simpan Perubahan'
                              : auth.isAdmin
                                  ? 'Tambah Reservasi'
                                  : 'Kirim Reservasi ke Hotel',
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, int idx) => Row(
    children: [
      Container(width: 4, height: 20,
          decoration: BoxDecoration(color: AppTheme.accent,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Icon(icon, size: 17, color: AppTheme.primary),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.bold, color: AppTheme.textPri)),
    ],
  ).animate(delay: Duration(milliseconds: 60 * idx))
      .fadeIn(duration: 300.ms);

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      String? Function(String?)? validator}) =>
    TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );

  Widget _counter(String label, int value, int min, int max,
      void Function(int) onChanged) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider)),
      child: Row(children: [
        Text(label, style: const TextStyle(color: AppTheme.textSec)),
        const Spacer(),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppTheme.primary,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('$value', style: const TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: AppTheme.textPri)),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppTheme.primary,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
      ]),
    );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _PricePreview extends StatelessWidget {
  final int harga;
  const _PricePreview({super.key, required this.harga});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark]),
      borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      const Icon(Icons.calculate_outlined, color: AppTheme.accent),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estimasi Total', style: TextStyle(
            color: Colors.white60, fontSize: 12)),
        Text(formatRupiah(harga), style: const TextStyle(
            color: AppTheme.accent, fontSize: 18,
            fontWeight: FontWeight.bold)),
      ]),
    ]),
  ).animate().fadeIn(duration: 300.ms).scale(
      begin: const Offset(0.96, 0.96), end: const Offset(1, 1),
      duration: 300.ms);
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isActive;
  final VoidCallback onTap;
  const _DateChip({required this.label, required this.date,
      required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppTheme.primary : AppTheme.divider),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 10,
            color: isActive ? Colors.white70 : AppTheme.textSec)),
        Text(date != null ? formatDate(date!.toIso8601String()) : '—',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppTheme.textPri)),
      ]),
    ),
  );
}

class _DateDisplay extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Color color;
  const _DateDisplay({required this.label, required this.date,
      required this.color});
  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSec)),
    Text(
      date != null ? formatDate(date!.toIso8601String()) : '—',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
    ),
  ]);
}
