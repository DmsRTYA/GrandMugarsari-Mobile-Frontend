// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/app_constants.dart';

class AuthService {
  static const _tokenKey = 'access_token';
  static const _userKey  = 'user_data';

  // ── Token storage ───────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_tokenKey);
  }

  Future<void> saveUser(User user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getStoredUser() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_userKey);
    if (raw == null) return null;
    try { return User.fromJson(jsonDecode(raw) as Map<String, dynamic>); }
    catch (_) { return null; }
  }

  Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_tokenKey);
    await p.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  // ── API calls ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        final data        = body['data']  as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        // backend returns user object; role may be included
        final userJson    = data['user']  as Map<String, dynamic>;
        final user        = User.fromJson(userJson);
        await saveToken(accessToken);
        await saveUser(user);
        return {'success': true, 'user': user};
      }
      return {'success': false, 'message': body['message'] ?? 'Login gagal'};
    } catch (e) {
      return {'success': false,
        'message': 'Tidak dapat terhubung ke server. Pastikan backend aktif.'};
    }
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email,
          'password': password}),
      ).timeout(const Duration(seconds: 10));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return {'success': body['success'] == true,
        'message': body['message'] ?? 'Registrasi gagal'};
    } catch (_) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('$kBaseUrl/api/auth/logout'),
          headers: {'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    await clearSession();
  }
}
