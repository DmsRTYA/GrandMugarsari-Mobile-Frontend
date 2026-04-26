// lib/providers/reschedule_provider.dart

import 'package:flutter/foundation.dart';
import '../models/reschedule_request_model.dart';
import '../services/reschedule_service.dart';

enum RescheduleState { loading, loaded, error }

class RescheduleProvider extends ChangeNotifier {
  final _svc = RescheduleService();

  RescheduleState           _state    = RescheduleState.loading;
  List<RescheduleRequest>   _requests = [];
  String?                   _error;

  RescheduleState         get state    => _state;
  List<RescheduleRequest> get requests => _requests;
  String?                 get error    => _error;
  bool                    get isLoading => _state == RescheduleState.loading;

  /// Jumlah request pending — untuk badge notifikasi admin
  int get pendingCount =>
      _requests.where((r) => r.isPending).length;

  Future<void> load() async {
    _state = RescheduleState.loading;
    _error = null;
    notifyListeners();
    try {
      _requests = await _svc.getRequests();
      _state    = RescheduleState.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _state = RescheduleState.error;
    }
    notifyListeners();
  }

  /// Pelanggan: ajukan reschedule
  Future<Map<String, dynamic>> submit({
    required int    reservationId,
    required String newCheckIn,
    required String newCheckOut,
    String alasan = '',
  }) async {
    final r = await _svc.submitRequest(
      reservationId: reservationId,
      newCheckIn:    newCheckIn,
      newCheckOut:   newCheckOut,
      alasan:        alasan,
    );
    if (r['success'] == true) {
      // Tambahkan request baru ke list lokal
      if (r['data'] != null) {
        _requests.insert(0, r['data'] as RescheduleRequest);
        notifyListeners();
      }
    }
    return r;
  }

  /// Admin: approve atau reject
  Future<Map<String, dynamic>> process({
    required int    requestId,
    required String action,
    String catatanAdmin = '',
  }) async {
    final r = await _svc.processRequest(
      requestId:      requestId,
      action:         action,
      catatanAdmin:   catatanAdmin,
    );
    if (r['success'] == true) {
      // Update status lokal
      final idx = _requests.indexWhere((x) => x.id == requestId);
      if (idx != -1) {
        // Reload untuk sinkron dengan backend (jadwal reservasi juga berubah)
        await load();
      }
    }
    return r;
  }

  void reset() {
    _requests = [];
    _state    = RescheduleState.loading;
    _error    = null;
    notifyListeners();
  }
}
