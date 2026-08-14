import '../core/constants/api_endpoints.dart';
import '../core/network/http_client.dart';
import '../models/custom_list.dart';

class ListRepository {
  final HttpClient _httpClient;

  ListRepository({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  Future<List<CustomList>> getCustomLists() async {
    final response = await _httpClient.get(ApiEndpoints.customLists);
    final List list = response.data as List;
    return list.map((e) => CustomList.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CustomList> createCustomList(String name) async {
    final response = await _httpClient.post(
      ApiEndpoints.customLists,
      data: {'name': name},
    );
    return CustomList.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addItemToList(String listId, String imdbId) async {
    await _httpClient.post(
      '${ApiEndpoints.customLists}/$listId/items',
      data: {'imdbId': imdbId},
    );
  }

  Future<void> deleteList(String listId) async {
    await _httpClient.delete('${ApiEndpoints.customLists}/$listId');
  }
}