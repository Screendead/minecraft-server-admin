import 'dart:typed_data';

/// Abstract interface for HTTP client operations
/// This allows for easy mocking in tests
abstract class HttpClientInterface {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  Future<HttpResponse> post(String url,
      {Map<String, String>? headers, Object? body});
  Future<HttpResponse> put(String url,
      {Map<String, String>? headers, Object? body});
  Future<HttpResponse> delete(String url, {Map<String, String>? headers});
}

/// HTTP response wrapper
class HttpResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final Uint8List? bodyBytes;

  const HttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    this.bodyBytes,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
}
