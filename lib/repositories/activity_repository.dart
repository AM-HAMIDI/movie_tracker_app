import '../core/constants/api_endpoints.dart';
import '../core/network/http_client.dart';
import '../core/storage/local_cache_service.dart';
import '../models/comment_item.dart';
import '../models/user_stats.dart';

class ActivityRepository {
  final HttpClient _httpClient;
  final LocalCacheService _cacheService;

  ActivityRepository({
    HttpClient? httpClient,
    LocalCacheService? cacheService,
  })  : _httpClient = httpClient ?? HttpClient(),
        _cacheService = cacheService ?? LocalCacheService();

  Future<Map<String, dynamic>> getActivity(String imdbId) async {
    try {
      final response = await _httpClient.get(ApiEndpoints.activity(imdbId));
      final data = response.data as Map<String, dynamic>;
      await _cacheService.cacheActivity(imdbId, data);
      return data;
    } catch (_) {
      final cached = _cacheService.getCachedActivity(imdbId);
      if (cached != null) return cached;
      return {
        'watchStatus': 'None',
        'rating': 0,
        'isFavorite': false,
        'watchedEpisodes': <String>[],
      };
    }
  }

  Future<bool> updateActivity({
    required String imdbId,
    String? watchStatus,
    int? rating,
    bool? isFavorite,
    List<String>? watchedEpisodes,
  }) async {
    final payload = <String, dynamic>{'imdbId': imdbId};
    if (watchStatus != null) payload['watchStatus'] = watchStatus;
    if (rating != null) payload['rating'] = rating;
    if (isFavorite != null) payload['isFavorite'] = isFavorite;
    if (watchedEpisodes != null) payload['watchedEpisodes'] = watchedEpisodes;

    final response = await _httpClient.post(
      ApiEndpoints.updateActivity,
      data: payload,
    );

    if (response.statusCode == 200) {
      await _cacheService.cacheActivity(imdbId, response.data as Map<String, dynamic>);
      return true;
    }
    return false;
  }

  Future<List<CommentItem>> getComments(String imdbId) async {
    final response = await _httpClient.get(ApiEndpoints.comments(imdbId));
    final List list = response.data as List;
    return list.map((e) => CommentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommentItem> addComment(String imdbId, String text, bool hasSpoiler) async {
    final response = await _httpClient.post(
      ApiEndpoints.addComment,
      data: {
        'imdbId': imdbId,
        'text': text,
        'hasSpoiler': hasSpoiler,
      },
    );
    return CommentItem.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteComment(String commentId) async {
    // Reuses the exact same base path as your POST comment route
    await _httpClient.delete('${ApiEndpoints.addComment}/$commentId');
  }

  Future<UserStats> getUserStats() async {
    final response = await _httpClient.get(ApiEndpoints.statistics);
    return UserStats.fromJson(response.data as Map<String, dynamic>);
  }
}