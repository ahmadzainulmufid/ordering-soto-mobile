import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../model/order_request_dto.dart';

class OrderApiService {
  final DioClient _client;

  OrderApiService(this._client);

  /// Mengembalikan order_code dari backend (respons: {"data": {"order_code": ...}}).
  Future<String> createOrder(OrderRequestDto request) {
    return guardApi(() async {
      final res = await _client.dio.post('/orders', data: request.toJson());
      final data = unwrapData(res.data);
      final code = (data is Map ? (data['order_code'] ?? data['code']) : null);
      if (code == null) {
        throw const ApiException('Kode pesanan tidak ditemukan pada respons');
      }
      return code.toString();
    });
  }
}