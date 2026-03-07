import 'dart:convert';
import 'button_area.dart';

class FrameTemplate {
  final String id;
  final String name;
  final int numberOfPhotoStrips;
  final String framePath;
  final List<ButtonArea> photoAreas;
  final DateTime createdAt;
  final DateTime updatedAt;

  FrameTemplate({
    required this.id,
    required this.name,
    required this.numberOfPhotoStrips,
    required this.framePath,
    required this.photoAreas,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'numberOfPhotoStrips': numberOfPhotoStrips,
      'framePath': framePath,
      'photoAreas': photoAreas.map((area) => area.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert from JSON
  factory FrameTemplate.fromJson(Map<String, dynamic> json) {
    return FrameTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      numberOfPhotoStrips: json['numberOfPhotoStrips'] as int,
      framePath: json['framePath'] as String,
      photoAreas: (json['photoAreas'] as List)
          .map((area) => ButtonArea.fromJson(area))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert to JSON String
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Convert from JSON String
  factory FrameTemplate.fromJsonString(String jsonString) {
    return FrameTemplate.fromJson(jsonDecode(jsonString));
  }

  // Copy with
  FrameTemplate copyWith({
    String? id,
    String? name,
    int? numberOfPhotoStrips,
    String? framePath,
    List<ButtonArea>? photoAreas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FrameTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      numberOfPhotoStrips: numberOfPhotoStrips ?? this.numberOfPhotoStrips,
      framePath: framePath ?? this.framePath,
      photoAreas: photoAreas ?? this.photoAreas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
