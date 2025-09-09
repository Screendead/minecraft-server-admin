import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:minecraft_server_automation/common/interfaces/http_client.dart';

/// Adapter that wraps the http package to implement HttpClientInterface
class HttpClientAdapter implements HttpClientInterface {
  final http.Client _client;

  HttpClientAdapter(this._client);

  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    final response = await _client.get(Uri.parse(url), headers: headers);
    return _convertResponse(response);
  }

  @override
  Future<HttpResponse> post(String url,
      {Map<String, String>? headers, Object? body}) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _convertResponse(response);
  }

  @override
  Future<HttpResponse> put(String url,
      {Map<String, String>? headers, Object? body}) async {
    final response = await _client.put(
      Uri.parse(url),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _convertResponse(response);
  }

  @override
  Future<HttpResponse> delete(String url,
      {Map<String, String>? headers}) async {
    final response = await _client.delete(Uri.parse(url), headers: headers);
    return _convertResponse(response);
  }

  HttpResponse _convertResponse(http.Response response) {
    return HttpResponse(
      statusCode: response.statusCode,
      body: response.body,
      headers: response.headers,
      bodyBytes: response.bodyBytes,
    );
  }
}
