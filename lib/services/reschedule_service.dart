// lib/services/reschedule_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reschedule_request_model.dart';
import '../models/app_constants.dart';
import 'auth_service.dart';

class RescheduleService {
  final _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Pelanggan & Admin: ambil daftar reschedule requests
  Future<List<RescheduleRequest>> getRequests() async {
    final headers = await _headers();
    final res = await http
        .get(Uri.parse('$kBaseUrl/api/reschedule-requests'), headers: headers)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 401) throw Exception('Sesi habis. Silakan login.');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == true) {
      return (body['data'] as List)
          .map((e) => RescheduleRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(body['message'] ?? 'Gagal memuat data');
  }

  /// Pelanggan: ajukan permintaan reschedule
  Future<Map<String, dynamic>> submitRequest({
    required int    reservationId,
    required String newCheckIn,
    required String newCheckOut,
    String alasan = '',
  }) async {
    try {
      final headers = await _headers();
      final res = await http
          .post(
            Uri.parse('$kBaseUrl/api/reschedule-requests'),
            headers: headers,
            body: jsonEncode({
              'reservation_id': reservationId,
              'new_check_in':   newCheckIn,
              'new_check_out':  newCheckOut,
              'alasan':         alasan,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': body['success'] == true,
        'message': body['message'] ?? 'Gagal',
        if (body['data'] != null)
          'data': RescheduleRequest.fromJson(
              body['data'] as Map<String, dynamic>),
      };
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  /// Admin: setujui atau tolak request
  Future<Map<String, dynamic>> processRequest({
    required int    requestId,
    required String action, // 'approved' | 'rejected'
    String catatanAdmin = '',
  }) async {
    try {
      final headers = await _headers();
      final res = await http
          .patch(
            Uri.parse('$kBaseUrl/api/reschedule-requests/$requestId'),
            headers: headers,
            body: jsonEncode({
              'action':        action,
              'catatan_admin': catatanAdmin,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {
        'success': body['success'] == true,
        'message': body['message'] ?? 'Gagal',
      };
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
