// lib/providers/auth_provider.dart
// Provider untuk state autentikasi (login, logout, session)

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Tiga state UI: loading, error, idle
enum AuthState { idle, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.idle;
  User? _user;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // ─── Getters ───────────────────────────────────────────────────────────────
  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _state == AuthState.loading;

  // ─── Init ──────────────────────────────────────────────────────────────────

  /// Cek sesi tersimpan saat aplikasi dibuka
  Future<void> checkSession() async {
    _state = AuthState.loading;
    notifyListeners();

    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      _user = await _authService.getStoredUser();
      _isLoggedIn = _user != null;
    } else {
      _isLoggedIn = false;
    }

    _state = AuthState.idle;
    notifyListeners();
  }

  // ─── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email, password);

    if (result['success'] == true) {
      _user = result['user'] as User;
      _isLoggedIn = true;
      _state = AuthState.idle;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      _isLoggedIn = false;
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // ─── Register ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(username, email, password);

    _state = result['success'] == true ? AuthState.idle : AuthState.error;
    if (result['success'] != true) {
      _errorMessage = result['message'] as String?;
    }
    notifyListeners();
    return result;
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    _state = AuthState.idle;
    notifyListeners();
  }

  /// Reset error state
  void clearError() {
    _errorMessage = null;
    _state = AuthState.idle;
    notifyListeners();
  }
}
