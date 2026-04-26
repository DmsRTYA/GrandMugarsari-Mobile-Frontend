// lib/services/reservation_service.dart
// Layanan CRUD reservasi dengan JWT Bearer token

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';
import '../models/app_constants.dart';
import 'auth_service.dart';

class ReservationService {
  final AuthService _authService = AuthService();

  /// Buat header HTTP dengan JWT Bearer token
  Future<Map<String, String>> _authHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── READ ──────────────────────────────────────────────────────────────────

  /// Ambil semua reservasi milik user, dengan filter status opsional
  Future<List<Reservation>> getReservations({String? status}) async {
    try {
      final headers = await _authHeaders();
      final uri = Uri.parse('$kBaseUrl/api/reservations').replace(
        queryParameters: (status != null && status != 'all')
            ? {'status': status}
            : null,
      );
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw Exception('Sesi habis. Silakan login kembali.');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        final list = body['data'] as List<dynamic>;
        return list
            .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(body['message'] ?? 'Gagal memuat data');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }

  /// Ambil satu reservasi berdasarkan id
  Future<Reservation> getReservationById(int id) async {
    final headers = await _authHeaders();
    final response = await http
        .get(
          Uri.parse('$kBaseUrl/api/reservations/$id'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401) {
      throw Exception('Sesi habis. Silakan login kembali.');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] == true) {
      return Reservation.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Reservasi tidak ditemukan');
    }
  }

  // ─── CREATE ────────────────────────────────────────────────────────────────

  /// Tambah reservasi baru
  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            Uri.parse('$kBaseUrl/api/reservations'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return {
          'success': true,
          'message': body['message'],
          'data': Reservation.fromJson(body['data'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Gagal menambahkan reservasi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─── UPDATE ────────────────────────────────────────────────────────────────

  /// Update reservasi berdasarkan id
  Future<Map<String, dynamic>> updateReservation(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .put(
            Uri.parse('$kBaseUrl/api/reservations/$id'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        return {
          'success': true,
          'message': body['message'],
          'data': Reservation.fromJson(body['data'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Gagal memperbarui reservasi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ─── DELETE ────────────────────────────────────────────────────────────────

  /// Hapus reservasi berdasarkan id
  Future<Map<String, dynamic>> deleteReservation(int id) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .delete(
            Uri.parse('$kBaseUrl/api/reservations/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': body['success'] == true,
        'message': body['message'] ?? 'Gagal menghapus reservasi',
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
