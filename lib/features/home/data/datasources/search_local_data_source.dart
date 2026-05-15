import 'package:shared_preferences/shared_preferences.dart';

/// Persists recent search keywords (max 10).
class SearchLocalDataSource {
  static const String _keywordsKey = 'search_recent_keywords';
  static const int maxKeywords = 10;

  Future<List<String>> loadKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keywordsKey) ?? [];
  }

  Future<void> saveKeywords(List<String> keywords) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keywordsKey, keywords.take(maxKeywords).toList());
  }

  Future<void> clearKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keywordsKey);
  }
}
