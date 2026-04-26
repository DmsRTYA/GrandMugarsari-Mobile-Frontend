// lib/models/app_constants.dart

const String kBaseUrl = 'http://10.127.121.225:3000';
// Ganti dengan IP lokal untuk device fisik: 'http://192.168.1.x:3000'

const Map<String, int> kRoomTypes = {
  'Standard': 350000,
  'Superior': 500000,
  'Deluxe': 750000,
  'Junior Suite': 1100000,
  'Suite': 1800000,
  'Presidential': 3500000,
};

const List<String> kStatusOptions = [
  'Booking',
  'Dikonfirmasi',
  'Check-In',
  'Check-Out',
];

/// Role constants — backend menyimpan 'admin' atau 'staff' (default)
/// 'staff' di DB = ditampilkan sebagai 'Pelanggan' di UI
const String kRoleAdmin     = 'admin';
const String kRolePelanggan = 'staff'; // nilai DB tetap 'staff'
const String kRoleStaff     = kRolePelanggan; // alias kompatibilitas

int calcHarga(
    String jenisKamar, int jumlahKamar, DateTime checkIn, DateTime checkOut) {
  final price = kRoomTypes[jenisKamar] ?? 0;
  final nights = checkOut.difference(checkIn).inDays;
  return price * jumlahKamar * (nights < 1 ? 1 : nights);
}

String formatRupiah(int amount) {
  if (amount == 0) return 'Rp 0';
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp ${buf.toString()}';
}

String formatDate(String dateStr) {
  try {
    final d = DateTime.parse(dateStr);
    const m = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  } catch (_) {
    return dateStr;
  }
}

String formatDateLong(String dateStr) {
  try {
    final d = DateTime.parse(dateStr);
    const m = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  } catch (_) {
    return dateStr;
  }
}

String formatDateTime(String dateStr) {
  try {
    final d = DateTime.parse(dateStr);
    const m = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month - 1]} ${d.year}  $hh:$mm';
  } catch (_) {
    return dateStr;
  }
}
