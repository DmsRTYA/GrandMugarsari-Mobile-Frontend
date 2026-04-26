// lib/models/reschedule_request_model.dart

import 'app_constants.dart';

class RescheduleRequest {
  final int    id;
  final int    reservationId;
  final int    userId;
  final String oldCheckIn;
  final String oldCheckOut;
  final String newCheckIn;
  final String newCheckOut;
  final String alasan;
  /// 'pending' | 'approved' | 'rejected'
  final String status;
  final String catatanAdmin;
  final String createdAt;
  final String updatedAt;

  // Join fields (tersedia di admin view)
  final String? namaPelanggan;
  final String? namaTamu;
  final String? jenisKamar;
  final int?    jumlahKamar;

  const RescheduleRequest({
    required this.id,
    required this.reservationId,
    required this.userId,
    required this.oldCheckIn,
    required this.oldCheckOut,
    required this.newCheckIn,
    required this.newCheckOut,
    required this.alasan,
    required this.status,
    required this.catatanAdmin,
    required this.createdAt,
    required this.updatedAt,
    this.namaPelanggan,
    this.namaTamu,
    this.jenisKamar,
    this.jumlahKamar,
  });

  factory RescheduleRequest.fromJson(Map<String, dynamic> j) =>
      RescheduleRequest(
        id:            (j['id'] as num).toInt(),
        reservationId: (j['reservation_id'] as num).toInt(),
        userId:        (j['user_id'] as num).toInt(),
        oldCheckIn:    j['old_check_in']  as String? ?? '',
        oldCheckOut:   j['old_check_out'] as String? ?? '',
        newCheckIn:    j['new_check_in']  as String? ?? '',
        newCheckOut:   j['new_check_out'] as String? ?? '',
        alasan:        j['alasan']        as String? ?? '',
        status:        j['status']        as String? ?? 'pending',
        catatanAdmin:  j['catatan_admin'] as String? ?? '',
        createdAt:     j['created_at']    as String? ?? '',
        updatedAt:     j['updated_at']    as String? ?? '',
        namaPelanggan: j['nama_pelanggan'] as String?,
        namaTamu:      j['nama_tamu']     as String?,
        jenisKamar:    j['jenis_kamar']   as String?,
        jumlahKamar:   (j['jumlah_kamar'] as num?)?.toInt(),
      );

  bool get isPending  => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get statusLabel {
    switch (status) {
      case 'pending':  return 'Menunggu';
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      default:         return status;
    }
  }

  String get formattedOldDates =>
      '${formatDate(oldCheckIn)} → ${formatDate(oldCheckOut)}';
  String get formattedNewDates =>
      '${formatDate(newCheckIn)} → ${formatDate(newCheckOut)}';
}
