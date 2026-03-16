import 'package:shared_preferences/shared_preferences.dart';

class CountdownSettingsDatasource {
  static const String _keyCountdownDuration = 'countdown_duration';

  Future<void> saveCountdownDuration(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCountdownDuration, seconds);
    } catch (e) {
      throw Exception('Failed to save countdown duration: $e');
    }
  }

  Future<int> loadCountdownDuration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyCountdownDuration) ?? 3;
    } catch (e) {
      // Jika error, return default 3 detik
      return 3;
    }
  }

  Future<void> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCountdownDuration);
    } catch (e) {
      throw Exception('Failed to reset countdown duration: $e');
    }
  }
}
