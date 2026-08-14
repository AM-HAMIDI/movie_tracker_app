import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalCacheService {
  static const String _mediaBoxName = 'media_cache_box';
  static const String _searchBoxName = 'search_cache_box';
  static const String _activityBoxName = 'activity_cache_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(_mediaBoxName),
      Hive.openBox(_searchBoxName),
      Hive.openBox(_activityBoxName),
    ]);
  }

  Box get _mediaBox => Hive.box(_mediaBoxName);
  Box get _searchBox => Hive.box(_searchBoxName);
  Box get _activityBox => Hive.box(_activityBoxName);

  // --- Media Details Caching ---
  Future<void> cacheMediaDetail(String imdbId, Map<String, dynamic> json) async {
    await _mediaBox.put('detail_$imdbId', jsonEncode(json));
  }

  Map<String, dynamic>? getCachedMediaDetail(String imdbId) {
    final raw = _mediaBox.get('detail_$imdbId');
    if (raw != null) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    return null;
  }

  // --- Search Results Caching ---
  Future<void> cacheSearchResults(String query, List<dynamic> jsonList) async {
    await _searchBox.put(query.toLowerCase(), jsonEncode(jsonList));
  }

  List<dynamic>? getCachedSearchResults(String query) {
    final raw = _searchBox.get(query.toLowerCase());
    if (raw != null) {
      return jsonDecode(raw) as List<dynamic>;
    }
    return null;
  }

  // --- User Activity Caching ---
  Future<void> cacheActivity(String imdbId, Map<String, dynamic> json) async {
    await _activityBox.put('act_$imdbId', jsonEncode(json));
  }

  Map<String, dynamic>? getCachedActivity(String imdbId) {
    final raw = _activityBox.get('act_$imdbId');
    if (raw != null) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearCache() async {
    await Future.wait([
      _mediaBox.clear(),
      _searchBox.clear(),
      _activityBox.clear(),
    ]);
  }
}