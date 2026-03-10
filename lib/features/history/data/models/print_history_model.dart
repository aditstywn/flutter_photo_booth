class PrintHistoryModel {
  final String date; // Format: yyyy-MM-dd
  final int printCount;

  PrintHistoryModel({
    required this.date,
    required this.printCount,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'printCount': printCount,
    };
  }

  // Create from JSON
  factory PrintHistoryModel.fromJson(Map<String, dynamic> json) {
    return PrintHistoryModel(
      date: json['date'] as String,
      printCount: json['printCount'] as int,
    );
  }

  // Copy with method for immutability
  PrintHistoryModel copyWith({
    String? date,
    int? printCount,
  }) {
    return PrintHistoryModel(
      date: date ?? this.date,
      printCount: printCount ?? this.printCount,
    );
  }
}
