import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// true jika login berhasil.
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    if (identifier.isEmpty || password.isEmpty) {
      _error = 'Email/nomor WhatsApp dan password wajib diisi';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.login(identifier: identifier, password: password);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Gagal masuk, coba lagi';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}