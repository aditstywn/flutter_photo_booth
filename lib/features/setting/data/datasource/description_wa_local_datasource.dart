import 'package:shared_preferences/shared_preferences.dart';

class DescriptionWaLocalDatasource {
  static const String _keyDescription = 'description';

  Future<void> saveDescription(String description) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDescription, description);
    } catch (e) {
      throw Exception('Failed to save description: $e');
    }
  }

  Future<String> loadDescription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyDescription) ?? '';
    } catch (e) {
      // Jika error, return default description
      return '';
    }
  }
}
