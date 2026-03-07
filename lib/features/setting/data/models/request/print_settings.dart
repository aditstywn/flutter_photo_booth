class PrintSettings {
  final double brightness; // 1.0 - 1.5
  final double contrast; // 1.0 - 1.5
  final int threshold; // 100 - 200

  PrintSettings({
    this.brightness = 1.4,
    this.contrast = 1.05,
    this.threshold = 170,
  });

  // Default preset: Sangat Cerah
  factory PrintSettings.defaultSettings() {
    return PrintSettings(
      brightness: 1.4,
      contrast: 1.05,
      threshold: 170,
    );
  }

  // Preset: Cerah
  factory PrintSettings.bright() {
    return PrintSettings(
      brightness: 1.3,
      contrast: 1.1,
      threshold: 160,
    );
  }

  // Preset: Normal
  factory PrintSettings.normal() {
    return PrintSettings(
      brightness: 1.2,
      contrast: 1.15,
      threshold: 140,
    );
  }

  // Preset: Gelap (Kontras Tinggi)
  factory PrintSettings.dark() {
    return PrintSettings(
      brightness: 1.1,
      contrast: 1.3,
      threshold: 128,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brightness': brightness,
      'contrast': contrast,
      'threshold': threshold,
    };
  }

  factory PrintSettings.fromJson(Map<String, dynamic> json) {
    return PrintSettings(
      brightness: (json['brightness'] as num?)?.toDouble() ?? 1.4,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 1.05,
      threshold: (json['threshold'] as num?)?.toInt() ?? 170,
    );
  }

  PrintSettings copyWith({
    double? brightness,
    double? contrast,
    int? threshold,
  }) {
    return PrintSettings(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      threshold: threshold ?? this.threshold,
    );
  }

  @override
  String toString() {
    return 'PrintSettings(brightness: $brightness, contrast: $contrast, threshold: $threshold)';
  }
}
