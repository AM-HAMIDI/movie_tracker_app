import '../core/constants/api_endpoints.dart';
import '../core/network/http_client.dart';
import '../models/custom_list.dart';

class ListRepository {
  final HttpClient _httpClient;

  ListRepository({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  Future<List<CustomList>> getCustomLists() async {
    final response = await _httpClient.get(ApiEndpoints.customLists);
    
    List<dynamic> listData = [];

    if (response.data is List) {
      listData = response.data as List;
    } else if (response.data is Map<String, dynamic>) {
      final mapData = response.data as Map<String, dynamic>;
      if (mapData.containsKey('data') && mapData['data'] is List) {
        listData = mapData['data'];
      } else if (mapData.containsKey('watchStatus')) {
        // Fail gracefully if the backend routing bug somehow occurs again
        throw Exception('Backend returned an Activity instead of Lists!');
      }
    }

    // Safely map MongoDB _id to Dart id, and items to itemImdbIds
    return listData.map((e) {
      final map = e as Map<String, dynamic>;
      map['id'] = map['id'] ?? map['_id'];
      map['itemImdbIds'] = map['itemImdbIds'] ?? map['items'] ?? [];
      return CustomList.fromJson(map);
    }).toList();
  }

  Future<CustomList> createCustomList(String name) async {
    final response = await _httpClient.post(
      ApiEndpoints.customLists,
      data: {'name': name},
    );
    
    Map<String, dynamic> responseData;
    if (response.data is Map<String, dynamic>) {
      final mapData = response.data as Map<String, dynamic>;
      responseData = (mapData.containsKey('data') && mapData['data'] is Map) 
          ? mapData['data'] 
          : mapData;
    } else {
      responseData = response.data;
    }

    // Map MongoDB syntax before parsing
    responseData['id'] = responseData['id'] ?? responseData['_id'];
    responseData['itemImdbIds'] = responseData['itemImdbIds'] ?? responseData['items'] ?? [];
    
    return CustomList.fromJson(responseData);
  }

  Future<void> addItemToList(String listId, String imdbId) async {
    await _httpClient.post(
      '${ApiEndpoints.customLists}/$listId/items',
      data: {'imdbId': imdbId},
    );
  }

  Future<void> removeItemFromList(String listId, String imdbId) async {
    await _httpClient.delete(
      '${ApiEndpoints.customLists}/$listId/items/$imdbId',
    );
  }

  Future<void> deleteList(String listId) async {
    await _httpClient.delete('${ApiEndpoints.customLists}/$listId');
  }
}