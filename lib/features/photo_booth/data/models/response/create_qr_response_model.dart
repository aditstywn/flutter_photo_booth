import 'dart:convert';

class CreateQrResponseModel {
  final String? message;
  final String? expiredAt;
  final String? downloadUrl;
  final String? qrImageUrl;

  CreateQrResponseModel({
    this.message,
    this.expiredAt,
    this.downloadUrl,
    this.qrImageUrl,
  });

  factory CreateQrResponseModel.fromJson(String str) =>
      CreateQrResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CreateQrResponseModel.fromMap(Map<String, dynamic> json) =>
      CreateQrResponseModel(
        message: json["message"],
        expiredAt: json["expired_at"],
        downloadUrl: json["download_url"],
        qrImageUrl: json["qr_image_url"],
      );

  Map<String, dynamic> toMap() => {
    "message": message,
    "expired_at": expiredAt,
    "download_url": downloadUrl,
    "qr_image_url": qrImageUrl,
  };
}
