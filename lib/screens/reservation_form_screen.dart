// lib/screens/reservation_form_screen.dart
// Form tambah / edit reservasi dengan kalkulasi harga otomatis

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/reservation_model.dart';
import '../models/app_constants.dart';
import '../providers/reservation_provider.dart';
import '../widgets/app_theme.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaTamuCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _noIdentitasCtrl = TextEditingController();
  final _permintaanCtrl = TextEditingController();

  // State
  String _jenisKamar = kRoomTypes.keys.first;
  int _jumlahKamar = 1;
  int _jumlahTamu = 1;
  String _status = kStatusOptions.first;
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _isEdit = false;
  int? _editId;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final existing =
        ModalRoute.of(context)?.settings.arguments as Reservation?;
    if (existing != null && !_isEdit) {
      _isEdit = true;
      _editId = existing.id;
      _namaTamuCtrl.text = existing.namaTamu;
      _emailCtrl.text = existing.email;
      _teleponCtrl.text = existing.telepon;
      _noIdentitasCtrl.text = existing.noIdentitas;
      _permintaanCtrl.text = existing.permintaan;
      _jenisKamar = existing.jenisKamar;
      _jumlahKamar = existing.jumlahKamar;
      _jumlahTamu = existing.jumlahTamu;
      _status = existing.status;
      try {
        _checkIn = DateTime.parse(existing.checkIn);
        _checkOut = DateTime.parse(existing.checkOut);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _namaTamuCtrl.dispose();
    _emailCtrl.dispose();
    _teleponCtrl.dispose();
    _noIdentitasCtrl.dispose();
    _permintaanCtrl.dispose();
    super.dispose();
  }

  // Kalkulasi harga otomatis
  int get _totalHarga {
    if (_checkIn == null || _checkOut == null) return 0;
    return calcHarga(_jenisKamar, _jumlahKamar, _checkIn!, _checkOut!);
  }

  // Pilih tanggal
  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final initial = isCheckIn
        ? (_checkIn ?? now)
        : (_checkOut ?? (_checkIn?.add(const Duration(days: 1)) ?? now));
    final first = isCheckIn ? now : (_checkIn ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            secondary: AppTheme.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && !_checkOut!.isAfter(picked)) {
            _checkOut = picked.add(const Duration(days: 1));
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal check-in dan check-out wajib diisi'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'nama_tamu': _namaTamuCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'telepon': _teleponCtrl.text.trim(),
      'no_identitas': _noIdentitasCtrl.text.trim(),
      'jenis_kamar': _jenisKamar,
      'jumlah_kamar': _jumlahKamar,
      'check_in': _checkIn!.toIso8601String().split('T').first,
      'check_out': _checkOut!.toIso8601String().split('T').first,
      'jumlah_tamu': _jumlahTamu,
      'status': _status,
      'permintaan': _permintaanCtrl.text.trim(),
    };

    final provider = context.read<ReservationProvider>();
    final result = _isEdit
        ? await provider.updateReservation(_editId!, data)
        : await provider.createReservation(data);

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] as String? ?? ''),
        backgroundColor:
            result['success'] == true ? AppTheme.success : AppTheme.error,
      ),
    );
    if (result['success'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Reservasi' : 'Tambah Reservasi'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Harga Preview ───────────────────────────────────────
              if (_checkIn != null && _checkOut != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF0F3460)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_outlined,
                          color: AppTheme.accent),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimasi Harga',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                          Text(
                            formatRupiah(_totalHarga),
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // ── Data Tamu ───────────────────────────────────────────
              _buildSectionTitle('Data Tamu', Icons.person_outline),
              const SizedBox(height: 12),

              _buildField(
                controller: _namaTamuCtrl,
                label: 'Nama Tamu',
                icon: Icons.person,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              _buildField(
                controller: _emailCtrl,
                label: 'Email Tamu',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _buildField(
                controller: _teleponCtrl,
                label: 'No. Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              _buildField(
                controller: _noIdentitasCtrl,
                label: 'No. Identitas (KTP/SIM/Paspor)',
                icon: Icons.badge_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),

              // Jumlah Tamu
              _buildCounter(
                label: 'Jumlah Tamu',
                value: _jumlahTamu,
                min: 1,
                max: 20,
                onChanged: (v) => setState(() => _jumlahTamu = v),
              ),
              const SizedBox(height: 20),

              // ── Detail Kamar ────────────────────────────────────────
              _buildSectionTitle('Detail Kamar', Icons.hotel_outlined),
              const SizedBox(height: 12),

              // Jenis Kamar
              DropdownButtonFormField<String>(
                value: _jenisKamar,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kamar',
                  prefixIcon: Icon(Icons.bed),
                ),
                items: kRoomTypes.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          '${e.key} — ${formatRupiah(e.value)}/malam',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _jenisKamar = v!),
              ),
              const SizedBox(height: 12),

              _buildCounter(
                label: 'Jumlah Kamar',
                value: _jumlahKamar,
                min: 1,
                max: 10,
                onChanged: (v) => setState(() => _jumlahKamar = v),
              ),
              const SizedBox(height: 20),

              // ── Tanggal ─────────────────────────────────────────────
              _buildSectionTitle('Tanggal Menginap', Icons.calendar_month),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DatePicker(
                      label: 'Check-In',
                      date: _checkIn,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePicker(
                      label: 'Check-Out',
                      date: _checkOut,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Status & Permintaan ─────────────────────────────────
              _buildSectionTitle('Info Tambahan', Icons.info_outline),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status Reservasi',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: kStatusOptions
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _permintaanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Permintaan Khusus (opsional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

              // ── Submit Button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _isEdit ? 'Simpan Perubahan' : 'Tambah Reservasi',
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildCounter({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary)),
          const Spacer(),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.primary,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.primary,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }
}

// ─── Date Picker Widget ──────────────────────────────────────────────────────

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePicker({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? AppTheme.accent : AppTheme.divider,
            width: date != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: date != null ? AppTheme.accent : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  date != null ? _fmt(date!) : 'Pilih Tanggal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                    color: date != null
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
