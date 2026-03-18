import 'dart:convert';

class SuccessResponseModel {
  final bool? success;
  final String? message;

  SuccessResponseModel({this.success, this.message});

  factory SuccessResponseModel.fromJson(String str) =>
      SuccessResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SuccessResponseModel.fromMap(Map<String, dynamic> json) =>
      SuccessResponseModel(success: json["success"], message: json["message"]);

  Map<String, dynamic> toMap() => {"success": success, "message": message};
}
