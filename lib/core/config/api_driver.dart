import 'package:http/http.dart' as http;

import 'url.dart';

enum ApiMethod { get, post, put, delete }

extension ApiMethodExtension on ApiMethod {
  String get name {
    switch (this) {
      case ApiMethod.get:
        return 'GET';
      case ApiMethod.post:
        return 'POST';
      case ApiMethod.put:
        return 'PUT';
      case ApiMethod.delete:
        return 'DELETE';
    }
  }
}

class ApiDriver {
  Future<http.Response> request({
    required ApiMethod method,
    required String url,
    body,
    bool isMultipart = false,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    // final token = await AuthLocalDatasource().getAccessToken();

    final headers = isMultipart
        ? <String, String>{
            'Accept': 'application/json',
            // 'Authorization': 'Bearer $token',
          }
        : <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            // 'Authorization': 'Bearer $token',
          };

    final Uri uri = _buildUri(url);

    switch (method) {
      case ApiMethod.post:
        if (isMultipart) {
          final request = http.MultipartRequest(method.name, uri);
          request.headers.addAll(headers);
          if (fields != null) request.fields.addAll(fields);
          if (files != null) request.files.addAll(files);
          final streamed = await request.send();
          return http.Response.fromStream(streamed);
        }
        return await http.post(uri, headers: headers, body: body);
      case ApiMethod.put:
        if (isMultipart) {
          final request = http.MultipartRequest(method.name, uri);
          request.headers.addAll(headers);
          if (fields != null) request.fields.addAll(fields);
          if (files != null) request.files.addAll(files);
          final streamed = await request.send();
          return http.Response.fromStream(streamed);
        }
        return await http.put(uri, headers: headers, body: body);
      case ApiMethod.delete:
        return await http.delete(uri, headers: headers);
      case ApiMethod.get:
        return await http.get(uri, headers: headers);
    }
  }

  Uri _buildUri(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Uri.parse(url);
    }

    final String normalizedBase = Url.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final String normalizedPath = url.replaceFirst(RegExp(r'^/+'), '');

    if (normalizedPath.isEmpty) {
      return Uri.parse(normalizedBase);
    }

    return Uri.parse('$normalizedBase/$normalizedPath');
  }
}
