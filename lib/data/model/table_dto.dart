import '../../domain/entities/table_entity.dart';

class TableDto {
  final String id;
  final String number;
  final bool isActive;

  const TableDto({
    required this.id,
    required this.number,
    required this.isActive,
  });

  factory TableDto.fromJson(Map<String, dynamic> json) {
    final active = json['is_active'];
    return TableDto(
      id: json['id'].toString(),
      number: (json['table_number'] ?? json['id']).toString(),
      isActive: active == null ? true : (active == true || active == 1),
    );
  }

  TableEntity toEntity() => TableEntity(id: id, number: number);
}