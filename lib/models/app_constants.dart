// lib/models/app_constants.dart
// Konstanta aplikasi yang mencerminkan backend constants.js

const String kBaseUrl = 'http://10.0.2.2:3000'; // Android emulator → localhost
// Ganti dengan IP lokal jika menggunakan device fisik, contoh: 'http://192.168.1.x:3000'

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

const Map<String, Map<String, String>> kStatusStyles = {
  'Booking': {
    'color': '#C9A84C',
    'bg': '#FDF8ED',
  },
  'Dikonfirmasi': {
    'color': '#3498db',
    'bg': '#EAF4FB',
  },
  'Check-In': {
    'color': '#2ecc71',
    'bg': '#EAFAF1',
  },
  'Check-Out': {
    'color': '#95a5a6',
    'bg': '#F2F3F4',
  },
};

/// Hitung total harga reservasi
int calcHarga(String jenisKamar, int jumlahKamar, DateTime checkIn, DateTime checkOut) {
  final pricePerNight = kRoomTypes[jenisKamar] ?? 0;
  final malam = checkOut.difference(checkIn).inDays;
  final nights = malam < 1 ? 1 : malam;
  return pricePerNight * jumlahKamar * nights;
}

/// Format angka ke Rupiah
String formatRupiah(int amount) {
  final parts = amount.toString().split('');
  final result = <String>[];
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && (parts.length - i) % 3 == 0) result.add('.');
    result.add(parts[i]);
  }
  return 'Rp ${result.join('')}';
}
