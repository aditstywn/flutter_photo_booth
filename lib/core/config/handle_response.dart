import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

Either<String, T> handleResponse<T>({
  required http.Response response,
  required T Function(String) fromJson,
  required String errorMessage,
}) {
  if (response.statusCode == 200) {
    return Right(fromJson(response.body));
  } else if (response.statusCode == 201) {
    return Right(fromJson(response.body));
  } else {
    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (responseBody['errors'] is Map<String, dynamic>) {
      final errorMap = responseBody['errors'] as Map<String, dynamic>;
      final List<String> errorMessages = [];

      for (final entry in errorMap.entries) {
        if (entry.value is List && (entry.value as List).isNotEmpty) {
          errorMessages.addAll((entry.value as List).map((e) => e.toString()));
        }
      }

      if (errorMessages.isNotEmpty) {
        return Left(errorMessages.join(', '));
      }
    }

    if (responseBody['message'] is String) {
      return Left(responseBody['message']);
    }

    if (responseBody['data'] is Map<String, dynamic>) {
      final String? message = responseBody['data']['detail'];
      if (message != null && message.isNotEmpty) {
        return Left(message);
      }
    }

    if (responseBody['detail'] is List) {
      final List details = responseBody['detail'];

      if (details.isNotEmpty) {
        final String message = details
            .map((e) => e['msg'] as String)
            .join(', ');
        return Left(message);
      }
    }

    if (responseBody['error'] is Map<String, dynamic> &&
        responseBody['error']?['notes'] is List) {
      final List notes = responseBody['error']['notes'];
      if (notes.isNotEmpty) {
        return Left(notes.join(', '));
      }
    }

    return Left(errorMessage);
  }
}
