import '../../core/network/token_storage.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../services/auth_api_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthApiService _api;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._api, this._tokenStorage);

  @override
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final token = await _api.login(identifier: identifier, password: password);
    await _tokenStorage.save(token);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _api.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }

  @override
  Future<CustomerProfileEntity> getProfile() async {
    final m = await _api.getProfile();
    final name = (m['name'] ?? m['full_name'] ?? m['customer_name'] ?? '')
        .toString()
        .trim();
    final phone = (m['phone'] ?? m['phone_number'] ?? '').toString().trim();
    return CustomerProfileEntity(
      name: name.isEmpty ? 'Pelanggan' : name,
      phone: phone,
    );
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  @override
  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.read();
    return token != null && token.isNotEmpty;
  }
}