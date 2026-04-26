// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { idle, loading, error }

class AuthProvider extends ChangeNotifier {
  final _svc = AuthService();

  AuthState _state   = AuthState.idle;
  User?     _user;
  String?   _error;
  bool      _loggedIn = false;

  AuthState get state      => _state;
  User?     get user       => _user;
  String?   get errorMessage => _error;
  bool      get isLoggedIn => _loggedIn;
  bool      get isLoading  => _state == AuthState.loading;
  bool      get isAdmin    => _user?.isAdmin ?? false;

  Future<void> checkSession() async {
    _state = AuthState.loading;
    notifyListeners();
    final ok = await _svc.isLoggedIn();
    if (ok) {
      _user    = await _svc.getStoredUser();
      _loggedIn = _user != null;
    } else {
      _loggedIn = false;
    }
    _state = AuthState.idle;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    final r = await _svc.login(email, password);
    if (r['success'] == true) {
      _user    = r['user'] as User;
      _loggedIn = true;
      _state   = AuthState.idle;
      notifyListeners();
      return true;
    }
    _error   = r['message'] as String?;
    _loggedIn = false;
    _state   = AuthState.error;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    _state = AuthState.loading;
    _error = null;
    notifyListeners();
    final r = await _svc.register(username, email, password);
    _state = r['success'] == true ? AuthState.idle : AuthState.error;
    if (r['success'] != true) _error = r['message'] as String?;
    notifyListeners();
    return r;
  }

  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();
    await _svc.logout();
    _user    = null;
    _loggedIn = false;
    _state   = AuthState.idle;
    notifyListeners();
  }

  void clearError() { _error = null; _state = AuthState.idle; notifyListeners(); }
}
