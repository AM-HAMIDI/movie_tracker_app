import '../config/app_config.dart';

class ApiEndpoints {
  // Auth Routes
  static String get login => '${AppConfig.baseUrl}/auth/login';
  static String get register => '${AppConfig.baseUrl}/auth/register';
  static String get profile => '${AppConfig.baseUrl}/auth/profile';
  static String get resetPassword => '${AppConfig.baseUrl}/auth/reset-password';

  // Media Routes
  static String get search => '${AppConfig.baseUrl}/media/search';
  static String get detail => '${AppConfig.baseUrl}/media/detail';
  static String seasonDetail(String imdbId, int seasonNum) =>
      '${AppConfig.baseUrl}/media/detail/$imdbId/season/$seasonNum';

  // Activity Routes
  static String activity(String imdbId) => '${AppConfig.baseUrl}/activity/$imdbId';
  static String get updateActivity => '${AppConfig.baseUrl}/activity/update';
  static String comments(String imdbId) => '${AppConfig.baseUrl}/activity/comments/$imdbId';
  static String get addComment => '${AppConfig.baseUrl}/activity/comments';
  static String get statistics => '${AppConfig.baseUrl}/activity/user/statistics';

  // Custom List Routes
  static String get customLists => '${AppConfig.baseUrl}/activity/lists';
  static String customListDetail(String listId) => '${AppConfig.baseUrl}/activity/lists/$listId';
}