import 'dart:convert';

class CreatePhotoboothResponseModel {
  final String? message;
  final Data? data;

  CreatePhotoboothResponseModel({this.message, this.data});

  factory CreatePhotoboothResponseModel.fromJson(String str) =>
      CreatePhotoboothResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CreatePhotoboothResponseModel.fromMap(Map<String, dynamic> json) =>
      CreatePhotoboothResponseModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {"message": message, "data": data?.toMap()};
}

class Data {
  final int? id;
  final String? token;

  Data({this.id, this.token});

  factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Data.fromMap(Map<String, dynamic> json) =>
      Data(id: json["id"], token: json["token"]);

  Map<String, dynamic> toMap() => {"id": id, "token": token};
}
