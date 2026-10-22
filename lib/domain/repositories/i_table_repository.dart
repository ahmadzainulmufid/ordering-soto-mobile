import '../entities/table_entity.dart';

abstract class ITableRepository {
  /// Hanya meja yang aktif.
  Future<List<TableEntity>> getTables();

  /// Untuk hasil scan QR meja (GET /tables/qr/:token).
  Future<TableEntity> getTableByQrToken(String token);
}