import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Dilempar saat user belum login dan mencoba checkout (Lazy Auth).
class NotAuthenticatedException implements Exception {
  const NotAuthenticatedException();

  @override
  String toString() => 'Silakan masuk terlebih dahulu';
}

/// Membungkus panggilan Dio dan mengubah DioException menjadi ApiException.
Future<T> guardApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    final data = e.response?.data;
    String? serverMessage;
    if (data is Map) {
      serverMessage = (data['message'] ?? data['error'])?.toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const ApiException('Koneksi ke server timeout, coba lagi');
      case DioExceptionType.connectionError:
        throw const ApiException('Tidak dapat terhubung ke server');
      default:
        throw ApiException(
          serverMessage ?? 'Terjadi kesalahan pada server',
          statusCode: e.response?.statusCode,
        );
    }
  }
}

/// Backend bisa mengembalikan {"data": ...} atau langsung objek/list.
dynamic unwrapData(dynamic body) {
  if (body is Map && body.containsKey('data')) return body['data'];
  return body;
}
