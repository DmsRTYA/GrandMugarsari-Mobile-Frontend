// lib/providers/reservation_provider.dart

import 'package:flutter/foundation.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';

enum ResState { loading, error, loaded }

class ReservationProvider extends ChangeNotifier {
  final _svc = ReservationService();

  ResState          _state  = ResState.loading;
  List<Reservation> _all    = [];
  List<Reservation> _shown  = [];
  String?           _error;
  String            _filter = 'all';
  String            _query  = '';

  ResState          get state      => _state;
  List<Reservation> get reservations => _shown;
  List<Reservation> get allReservations => _all;
  String?           get errorMessage => _error;
  String            get activeFilter => _filter;
  String            get searchQuery  => _query;
  bool              get isLoading   => _state == ResState.loading;

  // ── Stats ──────────────────────────────────────────────────────────────────
  int get total      => _all.length;
  int get booking    => _all.where((r) => r.status == 'Booking').length;
  int get dikonfirmasi => _all.where((r) => r.status == 'Dikonfirmasi').length;
  int get checkIn    => _all.where((r) => r.status == 'Check-In').length;
  int get checkOut   => _all.where((r) => r.status == 'Check-Out').length;
  int get pendapatan => _all.fold(0, (s, r) => s + r.totalHarga);

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> load() async {
    _state = ResState.loading;
    _error = null;
    notifyListeners();
    try {
      _all = await _svc.getReservations();
      _apply();
      _state = ResState.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _state = ResState.error;
    }
    notifyListeners();
  }

  // ── Filter / Search ────────────────────────────────────────────────────────
  void setFilter(String f) { _filter = f; _apply(); notifyListeners(); }
  void setSearch(String q) { _query = q.toLowerCase(); _apply(); notifyListeners(); }

  void _apply() {
    var r = List<Reservation>.from(_all);
    if (_filter != 'all') r = r.where((x) => x.status == _filter).toList();
    if (_query.isNotEmpty) {
      r = r.where((x) =>
        x.namaTamu.toLowerCase().contains(_query) ||
        x.email.toLowerCase().contains(_query) ||
        x.jenisKamar.toLowerCase().contains(_query) ||
        x.telepon.contains(_query)).toList();
    }
    _shown = r;
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final r = await _svc.create(data);
    if (r['success'] == true) {
      _all.insert(0, r['data'] as Reservation);
      _apply(); notifyListeners();
    }
    return r;
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final r = await _svc.update(id, data);
    if (r['success'] == true) {
      final idx = _all.indexWhere((x) => x.id == id);
      if (idx != -1) { _all[idx] = r['data'] as Reservation; _apply(); notifyListeners(); }
    }
    return r;
  }

  Future<Map<String, dynamic>> delete(int id) async {
    final r = await _svc.delete(id);
    if (r['success'] == true) {
      _all.removeWhere((x) => x.id == id);
      _apply(); notifyListeners();
    }
    return r;
  }

  void reset() {
    _all = []; _shown = []; _state = ResState.loading;
    _filter = 'all'; _query = ''; _error = null;
    notifyListeners();
  }
}
