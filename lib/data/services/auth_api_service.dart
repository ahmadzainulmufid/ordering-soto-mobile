import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';

class AuthApiService {
  final DioClient _client;

  AuthApiService(this._client);

  /// Mengembalikan token JWT.
  Future<String> login({
    required String identifier,
    required String password,
  }) {
    return guardApi(() async {
      final res = await _client.dio.post(
        '/customer/auth/login',
        data: {'email': identifier, 'password': password},
      );
      return _extractToken(res.data);
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return guardApi(() async {
      await _client.dio.post(
        '/customer/auth/register',
        data: {
          'full_name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
    });
  }

  Future<Map<String, dynamic>> getProfile() {
    return guardApi(() async {
      final res = await _client.dio.get('/customer/auth/profile');
      return Map<String, dynamic>.from(unwrapData(res.data) as Map);
    });
  }

  String _extractToken(dynamic body) {
    final data = unwrapData(body);
    final token = (data is Map ? data['access_token'] : null) ??
        (body is Map ? body['access_token'] : null);
    if (token == null) {
      throw const ApiException('Token tidak ditemukan pada respons login');
    }
    return token.toString();
  }
}