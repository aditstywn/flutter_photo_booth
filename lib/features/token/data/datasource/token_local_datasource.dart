import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';

import '../models/response/validate_token_response_model.dart';

class TokenLocalDatasource {
  final _k1 = "RARA";
  final _k2 = "2026";
  final _k3 = "SECRET";

  String get _secretKey => _k1 + _k2 + _k3;

  // String generateLicenseToken({required int activeDays}) {
  //   final expiredAt = DateTime.now()
  //       .add(Duration(days: activeDays))
  //       .millisecondsSinceEpoch;

  //   final random = Random().nextInt(9999).toString();

  //   final rawData = "$expiredAt|$random";
  //   final payloadBase64 = base64UrlEncode(utf8.encode(rawData));

  //   final hmac = Hmac(sha256, utf8.encode(_secretKey));
  //   final signature = hmac
  //       .convert(utf8.encode(payloadBase64))
  //       .toString()
  //       .substring(0, 8);

  //   // return "${payloadBase64.substring(0, 10)}-$signature";
  //   return "$payloadBase64-$signature";
  // }

  Future<Either<String, String>> generateLicenseToken(int activeDays) async {
    try {
      final now = DateTime.now();

      final issuedDate =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

      final random = Random().nextInt(999).toString();

      final rawData = "$issuedDate|$activeDays|$random";

      final payloadBase64 = base64UrlEncode(utf8.encode(rawData));

      final hmac = Hmac(sha256, utf8.encode(_secretKey));
      final signature = hmac
          .convert(utf8.encode(payloadBase64))
          .toString()
          .substring(0, 8);

      return Right("$payloadBase64-$signature");
    } catch (e) {
      return Left("Error occurred while generating token");
    }
  }

  // int? validateAndExtractExpired(String token) {
  //   try {
  //     final parts = token.split("-");
  //     if (parts.length != 2) return null;

  //     final payloadPart = parts[0];
  //     final signature = parts[1];

  //     final hmac = Hmac(sha256, utf8.encode(_secretKey));
  //     final expectedSignature = hmac
  //         .convert(utf8.encode(payloadPart))
  //         .toString()
  //         .substring(0, 8);

  //     if (signature != expectedSignature) return null;

  //     final decoded = utf8.decode(
  //       base64Url.decode(base64Url.normalize(payloadPart)),
  //     );

  //     final expiredAt = int.parse(decoded.split("|")[0]);

  //     return expiredAt;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<Either<String, ValidateTokenResponseModel>> validateToken(
    String token,
  ) async {
    try {
      final parts = token.split("-");
      if (parts.length != 2) {
        return Left("Token yang diberikan tidak valid");
      }

      final payloadPart = parts[0];
      final signature = parts[1];

      final hmac = Hmac(sha256, utf8.encode(_secretKey));
      final expectedSignature = hmac
          .convert(utf8.encode(payloadPart))
          .toString()
          .substring(0, 8);

      if (signature != expectedSignature) {
        return Left("Token yang diberikan tidak valid");
      }

      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(payloadPart)),
      );

      final values = decoded.split("|");

      final issuedDate = values[0];
      final activeDays = int.parse(values[1]);

      final now = DateTime.now();

      final today =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

      // hanya bisa login di hari token dibuat
      if (issuedDate != today) {
        return Left("Token sudah tidak berlaku");
      }

      final expiredAt = now
          .add(Duration(days: activeDays))
          .millisecondsSinceEpoch;

      return Right(ValidateTokenResponseModel(activeDays, expiredAt));
    } catch (e) {
      return Left("Error occurred while validating token");
    }
  }

  int getRemainingDays(int expiredAt) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = expiredAt - now;
    return (diff / (1000 * 60 * 60 * 24)).ceil();
  }
}
