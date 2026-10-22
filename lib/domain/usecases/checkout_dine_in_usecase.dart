import '../../core/network/api_exception.dart';
import '../entities/customer_entity.dart';
import '../repositories/i_auth_repository.dart';
import '../repositories/i_cart_repository.dart';

class CheckoutDineInUseCase {
  final IAuthRepository _authRepository;
  final ICartRepository _cartRepository;

  CheckoutDineInUseCase(this._authRepository, this._cartRepository);

  /// Mengembalikan order_code.
  /// Melempar [NotAuthenticatedException] jika belum login (atau token sudah
  /// tidak valid), sehingga UI menampilkan LoginModalSheet (Lazy Auth) lalu
  /// memanggil ulang use case ini setelah login berhasil.
  Future<String> call({required String tableId}) async {
    if (!await _authRepository.isLoggedIn()) {
      throw const NotAuthenticatedException();
    }

    final items = await _cartRepository.getItems();
    if (items.isEmpty) {
      throw const ApiException('Keranjang masih kosong');
    }

    // Backend mewajibkan customer_name, diambil dari profil pelanggan.
    final CustomerProfileEntity profile;
    try {
      profile = await _authRepository.getProfile();
    } on ApiException catch (e) {
      if (e.isUnauthorized) throw const NotAuthenticatedException();
      rethrow;
    }

    final orderCode = await _cartRepository.submitOrder(
      tableId: tableId,
      customerName: profile.name,
      customerPhone: profile.phone,
      items: items,
    );
    await _cartRepository.clear();
    return orderCode;
  }
}