import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/request/print_settings.dart';

class PrintSettingsDatasource {
  static const String _keyPrintSettings = 'print_settings';

  /// Simpan print settings
  Future<void> saveSettings(PrintSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(settings.toJson());
      await prefs.setString(_keyPrintSettings, jsonString);
    } catch (e) {
      throw Exception('Failed to save print settings: $e');
    }
  }

  /// Load print settings (return default jika belum ada)
  Future<PrintSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyPrintSettings);

      if (jsonString == null || jsonString.isEmpty) {
        return PrintSettings.defaultSettings();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PrintSettings.fromJson(json);
    } catch (e) {
      // Jika error, return default settings
      return PrintSettings.defaultSettings();
    }
  }

  /// Reset ke default settings
  Future<void> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPrintSettings);
    } catch (e) {
      throw Exception('Failed to reset print settings: $e');
    }
  }

  /// Apply preset
  Future<void> applyPreset(PrintSettings preset) async {
    await saveSettings(preset);
  }
}
