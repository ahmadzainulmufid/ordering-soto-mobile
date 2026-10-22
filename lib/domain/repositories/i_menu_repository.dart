import '../entities/menu_entity.dart';

abstract class IMenuRepository {
  Future<List<MenuEntity>> getMenus({String? categoryId});
  Future<List<MenuEntity>> searchMenus(String query);
  Future<MenuEntity> getMenuById(String id);
}
