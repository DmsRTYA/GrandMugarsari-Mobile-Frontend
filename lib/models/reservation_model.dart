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

  Reservation({
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
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      namaTamu: json['nama_tamu'] as String,
      email: json['email'] as String,
      telepon: json['telepon'] as String,
      noIdentitas: json['no_identitas'] as String,
      jenisKamar: json['jenis_kamar'] as String,
      jumlahKamar: json['jumlah_kamar'] as int,
      checkIn: json['check_in'] as String,
      checkOut: json['check_out'] as String,
      jumlahTamu: json['jumlah_tamu'] as int,
      status: json['status'] as String,
      permintaan: json['permintaan'] as String? ?? '',
      totalHarga: json['total_harga'] as int,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

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
      };

  /// Kembalikan salinan dengan field yang diubah
  Reservation copyWith({
    int? id,
    int? userId,
    String? namaTamu,
    String? email,
    String? telepon,
    String? noIdentitas,
    String? jenisKamar,
    int? jumlahKamar,
    String? checkIn,
    String? checkOut,
    int? jumlahTamu,
    String? status,
    String? permintaan,
    int? totalHarga,
    String? createdAt,
    String? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaTamu: namaTamu ?? this.namaTamu,
      email: email ?? this.email,
      telepon: telepon ?? this.telepon,
      noIdentitas: noIdentitas ?? this.noIdentitas,
      jenisKamar: jenisKamar ?? this.jenisKamar,
      jumlahKamar: jumlahKamar ?? this.jumlahKamar,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      jumlahTamu: jumlahTamu ?? this.jumlahTamu,
      status: status ?? this.status,
      permintaan: permintaan ?? this.permintaan,
      totalHarga: totalHarga ?? this.totalHarga,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Hitung jumlah malam
  int get jumlahMalam {
    try {
      final ci = DateTime.parse(checkIn);
      final co = DateTime.parse(checkOut);
      final diff = co.difference(ci).inDays;
      return diff < 1 ? 1 : diff;
    } catch (_) {
      return 1;
    }
  }
}
