import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../domain/repositories/i_auth_repository.dart';

class RegisterViewModel extends ChangeNotifier {
  final IAuthRepository _authRepository;

  RegisterViewModel(this._authRepository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// true jika akun berhasil dibuat. Setelah itu user langsung dimasukkan
  /// (auto-login) supaya bisa lanjut checkout.
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Gagal mendaftar, coba lagi';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Akun sudah jadi. Kalau auto-login gagal, user tetap bisa masuk manual
    // saat checkout, jadi tidak dianggap gagal.
    try {
      await _authRepository.login(identifier: email, password: password);
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return true;
  }
}