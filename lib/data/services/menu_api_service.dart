import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../model/menu_dto.dart';

class MenuApiService {
  final DioClient _client;

  MenuApiService(this._client);

  Future<List<MenuDto>> getProducts({String? categoryId}) {
    return guardApi(() async {
      final res = await _client.dio.get(
        '/products',
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
        },
      );
      return _parseList(res.data);
    });
  }

  Future<List<MenuDto>> searchProducts(String query) {
    return guardApi(() async {
      final res = await _client.dio.get(
        '/products/search',
        queryParameters: {'q': query},
      );
      return _parseList(res.data);
    });
  }

  Future<MenuDto> getProductById(String id) {
    return guardApi(() async {
      final res = await _client.dio.get('/products/$id');
      return MenuDto.fromJson(
        Map<String, dynamic>.from(unwrapData(res.data) as Map),
      );
    });
  }

  List<MenuDto> _parseList(dynamic body) {
    final data = unwrapData(body);
    if (data is! List) return [];
    return data
        .map((e) => MenuDto.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
