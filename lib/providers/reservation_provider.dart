// lib/providers/reservation_provider.dart
// Provider untuk state reservasi dengan three-state UI: loading, error, data

import 'package:flutter/foundation.dart';
import '../models/reservation_model.dart';
import '../services/reservation_service.dart';

/// Three-state UI sesuai ketentuan tugas
enum ReservationState { loading, error, loaded }

class ReservationProvider extends ChangeNotifier {
  final ReservationService _service = ReservationService();

  ReservationState _state = ReservationState.loading;
  List<Reservation> _reservations = [];
  List<Reservation> _filteredReservations = [];
  String? _errorMessage;
  String _activeFilter = 'all';
  String _searchQuery = '';

  // ─── Getters ───────────────────────────────────────────────────────────────
  ReservationState get state => _state;
  List<Reservation> get reservations => _filteredReservations;
  List<Reservation> get allReservations => _reservations;
  String? get errorMessage => _errorMessage;
  String get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _state == ReservationState.loading;

  // ─── Stats untuk Dashboard ─────────────────────────────────────────────────
  int get totalReservations => _reservations.length;
  int get bookingCount =>
      _reservations.where((r) => r.status == 'Booking').length;
  int get dikonfirmasiCount =>
      _reservations.where((r) => r.status == 'Dikonfirmasi').length;
  int get checkInCount =>
      _reservations.where((r) => r.status == 'Check-In').length;
  int get checkOutCount =>
      _reservations.where((r) => r.status == 'Check-Out').length;
  int get totalPendapatan =>
      _reservations.fold(0, (sum, r) => sum + r.totalHarga);

  // ─── Load Data ─────────────────────────────────────────────────────────────

  Future<void> loadReservations() async {
    _state = ReservationState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _reservations = await _service.getReservations();
      _applyFilters();
      _state = ReservationState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = ReservationState.error;
    }
    notifyListeners();
  }

  // ─── Filter & Search ───────────────────────────────────────────────────────

  void setFilter(String status) {
    _activeFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<Reservation>.from(_reservations);

    // Filter by status
    if (_activeFilter != 'all') {
      result = result.where((r) => r.status == _activeFilter).toList();
    }

    // Filter by search query (nama tamu, email, jenis kamar)
    if (_searchQuery.isNotEmpty) {
      result = result.where((r) {
        return r.namaTamu.toLowerCase().contains(_searchQuery) ||
            r.email.toLowerCase().contains(_searchQuery) ||
            r.jenisKamar.toLowerCase().contains(_searchQuery) ||
            r.telepon.contains(_searchQuery);
      }).toList();
    }

    _filteredReservations = result;
  }

  // ─── CRUD Operations ───────────────────────────────────────────────────────

  /// Tambah reservasi baru
  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> data,
  ) async {
    final result = await _service.createReservation(data);
    if (result['success'] == true) {
      final newRes = result['data'] as Reservation;
      _reservations.insert(0, newRes);
      _applyFilters();
      notifyListeners();
    }
    return result;
  }

  /// Update reservasi
  Future<Map<String, dynamic>> updateReservation(
    int id,
    Map<String, dynamic> data,
  ) async {
    final result = await _service.updateReservation(id, data);
    if (result['success'] == true) {
      final updated = result['data'] as Reservation;
      final idx = _reservations.indexWhere((r) => r.id == id);
      if (idx != -1) {
        _reservations[idx] = updated;
        _applyFilters();
        notifyListeners();
      }
    }
    return result;
  }

  /// Hapus reservasi
  Future<Map<String, dynamic>> deleteReservation(int id) async {
    final result = await _service.deleteReservation(id);
    if (result['success'] == true) {
      _reservations.removeWhere((r) => r.id == id);
      _applyFilters();
      notifyListeners();
    }
    return result;
  }

  /// Reset state (saat logout)
  void reset() {
    _reservations = [];
    _filteredReservations = [];
    _state = ReservationState.loading;
    _activeFilter = 'all';
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}
