import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/print_history_model.dart';

class PrintHistoryDatasource {
  static const String _keyPrintHistory = 'print_history';
  static const String _keyLastResetMonth = 'last_reset_month';

  /// Get all print history for the current month
  Future<List<PrintHistoryModel>> getPrintHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we need to reset for a new month
    await _checkAndResetIfNewMonth(prefs);

    final String? historyJson = prefs.getString(_keyPrintHistory);

    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded
          .map(
            (item) => PrintHistoryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add or update print count for today
  Future<void> recordPrint() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we need to reset for a new month
    await _checkAndResetIfNewMonth(prefs);

    final today = DateTime.now();
    final todayString = _formatDate(today);

    List<PrintHistoryModel> history = await getPrintHistory();

    // Find if today's record exists
    final todayIndex = history.indexWhere(
      (record) => record.date == todayString,
    );

    if (todayIndex != -1) {
      // Update existing record
      history[todayIndex] = history[todayIndex].copyWith(
        printCount: history[todayIndex].printCount + 1,
      );
    } else {
      // Add new record for today
      history.add(PrintHistoryModel(date: todayString, printCount: 1));
    }

    // Sort by date descending (newest first)
    history.sort((a, b) => b.date.compareTo(a.date));

    // Save to SharedPreferences
    await _saveHistory(prefs, history);
  }

  /// Get print count for a specific date
  Future<int> getPrintCountForDate(DateTime date) async {
    final history = await getPrintHistory();
    final dateString = _formatDate(date);

    final record = history.firstWhere(
      (record) => record.date == dateString,
      orElse: () => PrintHistoryModel(date: dateString, printCount: 0),
    );

    return record.printCount;
  }

  /// Get total prints for current month
  Future<int> getTotalPrintsThisMonth() async {
    final history = await getPrintHistory();
    int total = 0;
    for (var record in history) {
      total += record.printCount;
    }
    return total;
  }

  /// Clear all history (manual reset)
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrintHistory);
    await _updateLastResetMonth(prefs);
  }

  /// Check if we need to reset for a new month
  Future<void> _checkAndResetIfNewMonth(SharedPreferences prefs) async {
    final now = DateTime.now();
    final currentMonthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final lastResetMonth = prefs.getString(_keyLastResetMonth);

    if (lastResetMonth != currentMonthKey) {
      // New month detected, clear history
      await prefs.remove(_keyPrintHistory);
      await prefs.setString(_keyLastResetMonth, currentMonthKey);
    }
  }

  /// Update last reset month
  Future<void> _updateLastResetMonth(SharedPreferences prefs) async {
    final now = DateTime.now();
    final currentMonthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    await prefs.setString(_keyLastResetMonth, currentMonthKey);
  }

  /// Save history to SharedPreferences
  Future<void> _saveHistory(
    SharedPreferences prefs,
    List<PrintHistoryModel> history,
  ) async {
    final jsonList = history.map((record) => record.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyPrintHistory, jsonString);
  }

  /// Format date to yyyy-MM-dd
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
