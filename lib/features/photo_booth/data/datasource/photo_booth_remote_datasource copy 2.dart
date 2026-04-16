import 'dart:io';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_photo_booth/features/photo_booth/data/models/response/create_qr_response_model.dart';
import 'package:flutter_photo_booth/features/photo_booth/data/models/response/statistic_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../../../../core/config/api_driver.dart';
import '../../../../core/config/handle_response.dart';
import '../models/request/create_photobooth_request_model.dart';
import '../models/response/create_photobooth_response_model.dart';

String _compressImageForUploadIsolate(Map<String, dynamic> params) {
  final originalPath = params['path'] as String;
  final prefix = params['prefix'] as String;
  final maxLongEdge = params['maxLongEdge'] as int;
  final jpegQuality = params['jpegQuality'] as int;
  final minCompressBytes = params['minCompressBytes'] as int;

  final originalFile = File(originalPath);
  if (!originalFile.existsSync()) {
    return originalPath;
  }

  final originalBytes = originalFile.readAsBytesSync();
  final decoded = img.decodeImage(originalBytes);

  if (decoded == null) {
    return originalPath;
  }

  final longestEdge = math.max(decoded.width, decoded.height);
  final lowerPath = originalPath.toLowerCase();
  final isJpeg = lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg');
  final shouldResize = longestEdge > maxLongEdge;
  final shouldReencode = !isJpeg || originalBytes.length > minCompressBytes;

  if (!shouldResize && !shouldReencode) {
    return originalPath;
  }

  img.Image processed = decoded;
  if (shouldResize) {
    final scale = maxLongEdge / longestEdge;
    processed = img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
      interpolation: img.Interpolation.linear,
    );
  }

  final compressedBytes = img.encodeJpg(processed, quality: jpegQuality);

  // Jika tidak resize dan hasil kompresi nyaris sama/besar, pakai file asli.
  if (!shouldResize &&
      compressedBytes.length >= (originalBytes.length * 0.95)) {
    return originalPath;
  }

  final fileName =
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(10000)}.jpg';
  final compressedFile = File('${Directory.systemTemp.path}/$fileName');
  compressedFile.writeAsBytesSync(compressedBytes, flush: true);

  return compressedFile.path;
}

class PhotoBoothRemoteDatasource {
  final _driver = ApiDriver();

  static const int _maxTemplateLongEdge = 1000;
  static const int _maxPhotoOriLongEdge = 800;
  static const int _jpegQuality = 50;
  static const int _minCompressBytes = 200 * 1024;

  Future<File> _compressImageForUpload(
    File originalFile, {
    required String prefix,
    required int maxLongEdge,
  }) async {
    if (!await originalFile.exists()) {
      return originalFile;
    }

    final compressedPath = await compute(_compressImageForUploadIsolate, {
      'path': originalFile.path,
      'prefix': prefix,
      'maxLongEdge': maxLongEdge,
      'jpegQuality': _jpegQuality,
      'minCompressBytes': _minCompressBytes,
    });

    return File(compressedPath);
  }

  Future<Either<String, CreatePhotoboothResponseModel>> createFile(
    CreatePhotoboothRequestModel files,
  ) async {
    final tempCompressedFiles = <File>[];

    try {
      if (files.photoTemplate == null || !await files.photoTemplate!.exists()) {
        return const Left('Foto template tidak ditemukan');
      }

      final compressedTemplate = await _compressImageForUpload(
        files.photoTemplate!,
        prefix: 'photo_template',
        maxLongEdge: _maxTemplateLongEdge,
      );

      if (compressedTemplate.path != files.photoTemplate!.path) {
        tempCompressedFiles.add(compressedTemplate);
      }

      final photoTemplate = await http.MultipartFile.fromPath(
        'photo_template',
        compressedTemplate.path,
      );

      // final gifVidio = await http.MultipartFile.fromPath(
      //   'gif_vidio',
      //   files.gifVidio.path,
      // );

      List<http.MultipartFile> photoOri = [];
      for (var i = 0; i < (files.photoOri?.length ?? 0); i++) {
        final originalPhoto = files.photoOri?[i];
        if (originalPhoto == null || !await originalPhoto.exists()) {
          continue;
        }

        final compressedPhoto = await _compressImageForUpload(
          originalPhoto,
          prefix: 'photo_ori',
          maxLongEdge: _maxPhotoOriLongEdge,
        );

        if (compressedPhoto.path != originalPhoto.path) {
          tempCompressedFiles.add(compressedPhoto);
        }

        final photo = await http.MultipartFile.fromPath(
          'photo_ori[]',
          compressedPhoto.path,
        );
        photoOri.add(photo);
      }

      final response = await _driver.request(
        method: ApiMethod.post,
        url: '/photos',
        isMultipart: true,
        files: [photoTemplate, ...photoOri],
      );

      return handleResponse(
        response: response,
        fromJson: (String body) => CreatePhotoboothResponseModel.fromJson(body),
        errorMessage: 'Gagal mengupload foto',
      );
    } catch (e) {
      return const Left('Gagal mengupload foto');
    } finally {
      for (final file in tempCompressedFiles) {
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  // Future<Either<String, CreatePhotoboothResponseModel>> createFile(
  //   CreatePhotoboothRequestModel files,
  // ) async {
  //   try {
  //     final photoTemplate = await http.MultipartFile.fromPath(
  //       'photo_template',
  //       files.photoTemplate?.path ?? '',
  //     );

  //     // final gifVidio = await http.MultipartFile.fromPath(
  //     //   'gif_vidio',
  //     //   files.gifVidio.path,
  //     // );

  //     List<http.MultipartFile> photoOri = [];
  //     for (var i = 0; i < (files.photoOri?.length ?? 0); i++) {
  //       final photo = await http.MultipartFile.fromPath(
  //         'photo_ori[]',
  //         files.photoOri?[i].path ?? '',
  //       );
  //       photoOri.add(photo);
  //     }

  //     final response = await _driver.request(
  //       method: ApiMethod.post,
  //       url: '/photos',
  //       isMultipart: true,
  //       files: [photoTemplate, ...photoOri],
  //     );

  //     return handleResponse(
  //       response: response,
  //       fromJson: (String body) => CreatePhotoboothResponseModel.fromJson(body),
  //       errorMessage: 'Gagal mengupload foto',
  //     );
  //   } catch (e) {
  //     return const Left('Gagal mengupload foto');
  //   }
  // }

  Future<Either<String, CreatePhotoboothResponseModel>> createFileVidio(
    File files,
    int idPhoto,
  ) async {
    try {
      final gifVidio = await http.MultipartFile.fromPath(
        'gif_vidio',
        files.path,
      );

      final response = await _driver.request(
        method: ApiMethod.post,
        url: '/photos/$idPhoto/upload-video',
        isMultipart: true,
        files: [gifVidio],
      );

      return handleResponse(
        response: response,
        fromJson: (String body) => CreatePhotoboothResponseModel.fromJson(body),
        errorMessage: 'Gagal mengupload video',
      );
    } catch (e) {
      return const Left('Gagal mengupload video');
    }
  }

  Future<Either<String, CreateQrResponseModel>> createQr(String token) async {
    try {
      final response = await _driver.request(
        method: ApiMethod.get,
        url: '/download/$token/qr',
        body: '',
      );

      return handleResponse(
        response: response,
        fromJson: (String body) => CreateQrResponseModel.fromJson(body),
        errorMessage: 'Gagal membuat QR code',
      );
    } catch (e) {
      return const Left('Gagal membuat QR code');
    }
  }

  Future<Either<String, CreateQrResponseModel>> createQrVideo(
    String token,
  ) async {
    try {
      final response = await _driver.request(
        method: ApiMethod.get,
        url: '/download/$token/video/qr',
        body: '',
      );

      return handleResponse(
        response: response,
        fromJson: (String body) => CreateQrResponseModel.fromJson(body),
        errorMessage: 'Gagal membuat QR code',
      );
    } catch (e) {
      return const Left('Gagal membuat QR code');
    }
  }

  Future<Either<String, String>> deleteFile(int id) async {
    try {
      final response = await _driver.request(
        method: ApiMethod.delete,
        url: '/photos/$id',
        body: '',
      );

      return handleResponse(
        response: response,
        fromJson: (String body) => 'File berhasil dihapus',
        errorMessage: 'Gagal menghapus file',
      );
    } catch (e) {
      return const Left('Gagal menghapus file');
    }
  }

  Future<Either<String, String>> deleteAllFile() async {
    try {
      final response = await _driver.request(
        method: ApiMethod.delete,
        url: '/photos/destroy-all',
        body: '',
      );

      return handleResponse(
        response: response,
        fromJson: (String body) => 'File berhasil dihapus',
        errorMessage: 'Gagal menghapus file',
      );
    } catch (e) {
      return const Left('Gagal menghapus file');
    }
  }

  Future<Either<String, StatisticResponseModel>> statistic() async {
    try {
      final response = await _driver.request(
        method: ApiMethod.get,
        url: '/photos/storage-stats',
        body: '',
      );

      return handleResponse(
        response: response,
        fromJson: (String body) => StatisticResponseModel.fromJson(body),
        errorMessage: 'Gagal mengambil statistik file',
      );
    } catch (e) {
      return const Left('Gagal mengambil statistik file');
    }
  }
}
