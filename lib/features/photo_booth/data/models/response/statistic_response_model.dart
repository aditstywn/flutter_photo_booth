import 'dart:convert';

class StatisticResponseModel {
  final String? message;
  final Data? data;

  StatisticResponseModel({this.message, this.data});

  factory StatisticResponseModel.fromJson(String str) =>
      StatisticResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StatisticResponseModel.fromMap(Map<String, dynamic> json) =>
      StatisticResponseModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {"message": message, "data": data?.toMap()};
}

class Data {
  final int? totalFiles;
  final int? totalSizeBytes;
  final String? totalSize;
  final int? missingFiles;

  Data({
    this.totalFiles,
    this.totalSizeBytes,
    this.totalSize,
    this.missingFiles,
  });

  factory Data.fromJson(String str) => Data.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Data.fromMap(Map<String, dynamic> json) => Data(
    totalFiles: json["total_files"],
    totalSizeBytes: json["total_size_bytes"],
    totalSize: json["total_size"],
    missingFiles: json["missing_files"],
  );

  Map<String, dynamic> toMap() => {
    "total_files": totalFiles,
    "total_size_bytes": totalSizeBytes,
    "total_size": totalSize,
    "missing_files": missingFiles,
  };
}
