import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_photo_booth/features/photo_booth/data/models/response/create_qr_response_model.dart';
import 'package:flutter_photo_booth/features/photo_booth/data/models/response/statistic_response_model.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_driver.dart';
import '../../../../core/config/handle_response.dart';
import '../models/request/create_photobooth_request_model.dart';
import '../models/response/create_photobooth_response_model.dart';

class PhotoBoothRemoteDatasource {
  final _driver = ApiDriver();
  Future<Either<String, CreatePhotoboothResponseModel>> createFile(
    CreatePhotoboothRequestModel files,
  ) async {
    try {
      final photoTemplate = await http.MultipartFile.fromPath(
        'photo_template',
        files.photoTemplate?.path ?? '',
      );

      // final gifVidio = await http.MultipartFile.fromPath(
      //   'gif_vidio',
      //   files.gifVidio.path,
      // );

      List<http.MultipartFile> photoOri = [];
      for (var i = 0; i < (files.photoOri?.length ?? 0); i++) {
        final photo = await http.MultipartFile.fromPath(
          'photo_ori[]',
          files.photoOri?[i].path ?? '',
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
    }
  }

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
