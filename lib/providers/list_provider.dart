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
      _customLists = await _listRepository.getCustomLists();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createList(String name) async {
    try {
      final newList = await _listRepository.createCustomList(name);
      _customLists.add(newList);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteList(String listId) async {
    try {
      await _listRepository.deleteList(listId);
      _customLists.removeWhere((l) => l.id == listId);
      notifyListeners();
    } catch (_) {}
  }
}