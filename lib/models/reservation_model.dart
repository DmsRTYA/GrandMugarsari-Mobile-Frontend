// lib/models/reservation_model.dart

class Reservation {
  final int id;
  final int userId;
  final String namaTamu;
  final String email;
  final String telepon;
  final String noIdentitas;
  final String jenisKamar;
  final int jumlahKamar;
  final String checkIn;
  final String checkOut;
  final int jumlahTamu;
  final String status;
  final String permintaan;
  final int totalHarga;
  final String createdAt;
  final String updatedAt;
  /// Hanya terisi saat admin mengambil data (JOIN dengan tabel users)
  final String? namaPelanggan;

  const Reservation({
    required this.id,
    required this.userId,
    required this.namaTamu,
    required this.email,
    required this.telepon,
    required this.noIdentitas,
    required this.jenisKamar,
    required this.jumlahKamar,
    required this.checkIn,
    required this.checkOut,
    required this.jumlahTamu,
    required this.status,
    required this.permintaan,
    required this.totalHarga,
    required this.createdAt,
    required this.updatedAt,
    this.namaPelanggan,
  });

  factory Reservation.fromJson(Map<String, dynamic> j) => Reservation(
        id: (j['id'] as num).toInt(),
        userId: (j['user_id'] as num).toInt(),
        namaTamu: j['nama_tamu'] as String? ?? '',
        email: j['email'] as String? ?? '',
        telepon: j['telepon'] as String? ?? '',
        noIdentitas: j['no_identitas'] as String? ?? '',
        jenisKamar: j['jenis_kamar'] as String? ?? '',
        jumlahKamar: (j['jumlah_kamar'] as num?)?.toInt() ?? 1,
        checkIn: j['check_in'] as String? ?? '',
        checkOut: j['check_out'] as String? ?? '',
        jumlahTamu: (j['jumlah_tamu'] as num?)?.toInt() ?? 1,
        status: j['status'] as String? ?? 'Booking',
        permintaan: j['permintaan'] as String? ?? '',
        totalHarga: (j['total_harga'] as num?)?.toInt() ?? 0,
        createdAt: j['created_at'] as String? ?? '',
        updatedAt: j['updated_at'] as String? ?? '',
        namaPelanggan: j['nama_pelanggan'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'nama_tamu': namaTamu,
        'email': email,
        'telepon': telepon,
        'no_identitas': noIdentitas,
        'jenis_kamar': jenisKamar,
        'jumlah_kamar': jumlahKamar,
        'check_in': checkIn,
        'check_out': checkOut,
        'jumlah_tamu': jumlahTamu,
        'status': status,
        'permintaan': permintaan,
        'total_harga': totalHarga,
        'created_at': createdAt,
        'updated_at': updatedAt,
        if (namaPelanggan != null) 'nama_pelanggan': namaPelanggan,
      };

  int get jumlahMalam {
    try {
      final ci = DateTime.parse(checkIn);
      final co = DateTime.parse(checkOut);
      final d = co.difference(ci).inDays;
      return d < 1 ? 1 : d;
    } catch (_) {
      return 1;
    }
  }

  DateTime? get checkInDate {
    try { return DateTime.parse(checkIn); } catch (_) { return null; }
  }

  DateTime? get checkOutDate {
    try { return DateTime.parse(checkOut); } catch (_) { return null; }
  }
}
