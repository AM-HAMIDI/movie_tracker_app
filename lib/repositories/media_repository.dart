import '../core/constants/api_endpoints.dart';
import '../core/network/http_client.dart';
import '../core/storage/local_cache_service.dart';
import '../models/media_item.dart';
import '../models/episode_item.dart';

class MediaRepository {
  final HttpClient _httpClient;
  final LocalCacheService _cacheService;

  MediaRepository({
    HttpClient? httpClient,
    LocalCacheService? cacheService,
  })  : _httpClient = httpClient ?? HttpClient(),
        _cacheService = cacheService ?? LocalCacheService();

  Future<List<MediaItem>> searchMedia(String query) async {
    try {
      final response = await _httpClient.get(
        ApiEndpoints.search,
        queryParameters: {'q': query},
      );

      final List list = response.data as List;
      await _cacheService.cacheSearchResults(query, list);
      return list.map((e) => MediaItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // Offline fallback lookup
      final cached = _cacheService.getCachedSearchResults(query);
      if (cached != null) {
        return cached.map((e) => MediaItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      rethrow;
    }
  }

  Future<MediaItem> getMediaDetail(String imdbId) async {
    try {
      final response = await _httpClient.get('${ApiEndpoints.detail}/$imdbId');
      final data = response.data as Map<String, dynamic>;
      await _cacheService.cacheMediaDetail(imdbId, data);
      return MediaItem.fromJson(data);
    } catch (_) {
      final cached = _cacheService.getCachedMediaDetail(imdbId);
      if (cached != null) {
        return MediaItem.fromJson(cached);
      }
      rethrow;
    }
  }

  Future<List<EpisodeItem>> getSeasonEpisodes(String imdbId, int seasonNum) async {
    final response = await _httpClient.get(ApiEndpoints.seasonDetail(imdbId, seasonNum));
    final List list = response.data as List;
    return list.map((e) => EpisodeItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}