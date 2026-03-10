import 'dart:convert';

class VoucherModel {
  final String code;
  final DateTime expiryDate;
  final bool isUsed;
  final DateTime? usedAt;

  VoucherModel({
    required this.code,
    required this.expiryDate,
    this.isUsed = false,
    this.usedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'isUsed': isUsed,
      'usedAt': usedAt?.millisecondsSinceEpoch,
    };
  }

  factory VoucherModel.fromMap(Map<String, dynamic> map) {
    return VoucherModel(
      code: map['code'] ?? '',
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      isUsed: map['isUsed'] ?? false,
      usedAt: map['usedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['usedAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory VoucherModel.fromJson(String source) =>
      VoucherModel.fromMap(json.decode(source));

  VoucherModel copyWith({
    String? code,
    DateTime? expiryDate,
    bool? isUsed,
    DateTime? usedAt,
  }) {
    return VoucherModel(
      code: code ?? this.code,
      expiryDate: expiryDate ?? this.expiryDate,
      isUsed: isUsed ?? this.isUsed,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  bool isValid() {
    return !isUsed && !isExpired();
  }
}
