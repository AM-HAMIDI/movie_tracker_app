import 'package:flutter/material.dart';
import '../core/errors/app_exceptions.dart';
import '../models/media_item.dart';
import '../repositories/media_repository.dart';

class MediaProvider extends ChangeNotifier {
  final MediaRepository _mediaRepository;

  MediaProvider({MediaRepository? mediaRepository})
      : _mediaRepository = mediaRepository ?? MediaRepository();

  List<MediaItem> _popularTitles = [];
  List<MediaItem> _newReleases = [];
  List<MediaItem> _recommendedTitles = [];

  bool _isLoadingHome = false;
  String? _homeErrorMessage;

  List<MediaItem> get popularTitles => _popularTitles;
  List<MediaItem> get newReleases => _newReleases;
  List<MediaItem> get recommendedTitles => _recommendedTitles;
  bool get isLoadingHome => _isLoadingHome;
  String? get homeErrorMessage => _homeErrorMessage;

  Future<void> fetchHomeDashboard() async {
    _isLoadingHome = true;
    _homeErrorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _mediaRepository.searchMedia('Marvel'),
        _mediaRepository.searchMedia('2024'),
        _mediaRepository.searchMedia('Batman'),
      ]);

      _popularTitles = results[0];
      _newReleases = results[1];
      _recommendedTitles = results[2];
      _isLoadingHome = false;
      notifyListeners();
    } on AppException catch (e) {
      _homeErrorMessage = e.message;
      _isLoadingHome = false;
      notifyListeners();
    } catch (_) {
      _homeErrorMessage = 'Failed to load home dashboard. Please pull to refresh.';
      _isLoadingHome = false;
      notifyListeners();
    }
  }
}