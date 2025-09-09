import 'package:minecraft_server_automation/common/interfaces/http_client.dart';

/// Mock implementation of HttpClientInterface for testing
class MockHttpClient implements HttpClientInterface {
  // Test control properties
  bool shouldThrowOnRequest = false;
  String? throwMessage;
  Map<String, HttpResponse> _responses = {};
  List<HttpRequest> _requests = [];

  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    return _handleRequest('GET', url, headers: headers);
  }

  @override
  Future<HttpResponse> post(String url,
      {Map<String, String>? headers, Object? body}) async {
    return _handleRequest('POST', url, headers: headers, body: body);
  }

  @override
  Future<HttpResponse> put(String url,
      {Map<String, String>? headers, Object? body}) async {
    return _handleRequest('PUT', url, headers: headers, body: body);
  }

  @override
  Future<HttpResponse> delete(String url,
      {Map<String, String>? headers}) async {
    return _handleRequest('DELETE', url, headers: headers);
  }

  Future<HttpResponse> _handleRequest(String method, String url,
      {Map<String, String>? headers, Object? body}) async {
    if (shouldThrowOnRequest) {
      throw Exception(throwMessage ?? 'Mock HTTP error');
    }

    // Record the request
    _requests.add(HttpRequest(
      method: method,
      url: url,
      headers: headers ?? {},
      body: body,
      timestamp: DateTime.now(),
    ));

    // Return mock response
    final responseKey = '$method:$url';
    return _responses[responseKey] ??
        HttpResponse(
          statusCode: 200,
          body: '{}',
          headers: {'content-type': 'application/json'},
        );
  }

  // Test helper methods
  void setResponse(String method, String url, HttpResponse response) {
    _responses['$method:$url'] = response;
  }

  void setSuccessResponse(String method, String url, String body) {
    setResponse(
        method,
        url,
        HttpResponse(
          statusCode: 200,
          body: body,
          headers: {'content-type': 'application/json'},
        ));
  }

  void setErrorResponse(
      String method, String url, int statusCode, String body) {
    setResponse(
        method,
        url,
        HttpResponse(
          statusCode: statusCode,
          body: body,
          headers: {'content-type': 'application/json'},
        ));
  }

  List<HttpRequest> get requests => List.unmodifiable(_requests);
  void clearRequests() => _requests.clear();
  void reset() {
    _responses.clear();
    _requests.clear();
    shouldThrowOnRequest = false;
    throwMessage = null;
  }
}

/// Record of HTTP requests made
class HttpRequest {
  final String method;
  final String url;
  final Map<String, String> headers;
  final Object? body;
  final DateTime timestamp;

  const HttpRequest({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
    required this.timestamp,
  });
}
