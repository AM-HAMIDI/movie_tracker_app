import 'package:flutter/material.dart';
import '../models/custom_list.dart';
import '../repositories/list_repository.dart';

class ListProvider extends ChangeNotifier {
  final ListRepository _listRepository;

  ListProvider({ListRepository? listRepository})
      : _listRepository = listRepository ?? ListRepository();

  List<CustomList> _customLists = [];
  bool _isLoading = false;

  List<CustomList> get customLists => _customLists;
  bool get isLoading => _isLoading;

  Future<void> fetchCustomLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedLists = await _listRepository.getCustomLists();
      _customLists = fetchedLists; // Only update state if fetch was successful
    } catch (e) {
      debugPrint('🚨 ERROR FETCHING LISTS: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createList(String name) async {
    try {
      final newList = await _listRepository.createCustomList(name);
      _customLists.add(newList);
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating list: $e');
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      await _listRepository.deleteList(listId);
      _customLists.removeWhere((l) => l.id == listId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting list: $e');
    }
  }

  Future<void> addItemToList(String listId, String imdbId) async {
    try {
      await _listRepository.addItemToList(listId, imdbId);
      // Silent sync update
      _customLists = await _listRepository.getCustomLists();
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 BACKEND ERROR (Add to List): $e');
    }
  }

  Future<void> removeItemFromList(String listId, String imdbId) async {
    try {
      await _listRepository.removeItemFromList(listId, imdbId);
      // Silent sync update
      _customLists = await _listRepository.getCustomLists();
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 BACKEND ERROR (Remove from List): $e');
    }
  }
}