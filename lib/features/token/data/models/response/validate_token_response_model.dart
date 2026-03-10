import 'dart:convert';

class ValidateTokenResponseModel {
  final int? activeDays;
  final int? expiredAt;

  ValidateTokenResponseModel(this.activeDays, this.expiredAt);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'activeDays': activeDays, 'expiredAt': expiredAt};
  }

  factory ValidateTokenResponseModel.fromMap(Map<String, dynamic> map) {
    return ValidateTokenResponseModel(
      map['activeDays'] != null ? map['activeDays'] as int : null,
      map['expiredAt'] != null ? map['expiredAt'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ValidateTokenResponseModel.fromJson(String source) =>
      ValidateTokenResponseModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
