import '../entities/customer_entity.dart';

abstract class IAuthRepository {
  Future<void> login({required String identifier, required String password});

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<CustomerProfileEntity> getProfile();
  Future<void> logout();
  Future<bool> isLoggedIn();
}