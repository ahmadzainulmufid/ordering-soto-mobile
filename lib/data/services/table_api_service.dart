import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../model/table_dto.dart';

class TableApiService {
  final DioClient _client;

  TableApiService(this._client);

  Future<List<TableDto>> getTables() {
    return guardApi(() async {
      final res = await _client.dio.get('/tables');
      final data = unwrapData(res.data);
      if (data is! List) return <TableDto>[];
      return data
          .map((e) => TableDto.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Future<TableDto> getTableByQrToken(String token) {
    return guardApi(() async {
      final res = await _client.dio.get('/tables/qr/$token');
      return TableDto.fromJson(
        Map<String, dynamic>.from(unwrapData(res.data) as Map),
      );
    });
  }
}