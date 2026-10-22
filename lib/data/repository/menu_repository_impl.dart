import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/i_menu_repository.dart';
import '../services/menu_api_service.dart';

class MenuRepositoryImpl implements IMenuRepository {
  final MenuApiService _api;

  MenuRepositoryImpl(this._api);

  @override
  Future<List<MenuEntity>> getMenus({String? categoryId}) async {
    final dtos = await _api.getProducts(categoryId: categoryId);
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<List<MenuEntity>> searchMenus(String query) async {
    final dtos = await _api.searchProducts(query);
    return dtos.map((d) => d.toEntity()).toList();
  }

  @override
  Future<MenuEntity> getMenuById(String id) async {
    final dto = await _api.getProductById(id);
    return dto.toEntity();
  }
}
