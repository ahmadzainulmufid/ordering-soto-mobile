import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/i_table_repository.dart';
import '../services/table_api_service.dart';

class TableRepositoryImpl implements ITableRepository {
  final TableApiService _api;

  TableRepositoryImpl(this._api);

  @override
  Future<List<TableEntity>> getTables() async {
    final dtos = await _api.getTables();
    return dtos.where((d) => d.isActive).map((d) => d.toEntity()).toList();
  }

  @override
  Future<TableEntity> getTableByQrToken(String token) async {
    final dto = await _api.getTableByQrToken(token);
    return dto.toEntity();
  }
}