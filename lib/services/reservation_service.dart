// lib/services/reservation_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';
import '../models/app_constants.dart';
import 'auth_service.dart';

class ReservationService {
  final _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Reservation>> getReservations({String? status}) async {
    final headers = await _headers();
    final uri = Uri.parse('$kBaseUrl/api/reservations').replace(
      queryParameters:
          (status != null && status != 'all') ? {'status': status} : null,
    );
    final res =
        await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
    if (res.statusCode == 401) throw Exception('Sesi habis. Silakan login kembali.');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == true) {
      return (body['data'] as List)
          .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(body['message'] ?? 'Gagal memuat data');
  }

  Future<Reservation> getById(int id) async {
    final headers = await _headers();
    final res = await http
        .get(Uri.parse('$kBaseUrl/api/reservations/$id'), headers: headers)
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 401) throw Exception('Sesi habis. Silakan login kembali.');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] == true) {
      return Reservation.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception(body['message'] ?? 'Tidak ditemukan');
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final headers = await _headers();
      final res = await http
          .post(Uri.parse('$kBaseUrl/api/reservations'),
              headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return {
          'success': true,
          'message': body['message'],
          'data': Reservation.fromJson(body['data'] as Map<String, dynamic>),
        };
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal'};
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _headers();
      final res = await http
          .put(Uri.parse('$kBaseUrl/api/reservations/$id'),
              headers: headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return {
          'success': true,
          'message': body['message'],
          'data': Reservation.fromJson(body['data'] as Map<String, dynamic>),
        };
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal'};
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> delete(int id) async {
    try {
      final headers = await _headers();
      final res = await http
          .delete(Uri.parse('$kBaseUrl/api/reservations/$id'), headers: headers)
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
