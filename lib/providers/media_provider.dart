import 'package:flutter/material.dart';
import '../core/errors/app_exceptions.dart';
import '../models/media_item.dart';
import '../repositories/media_repository.dart';

class MediaProvider extends ChangeNotifier {
  final MediaRepository _mediaRepository;

  MediaProvider({MediaRepository? mediaRepository})
      : _mediaRepository = mediaRepository ?? MediaRepository();

  List<MediaItem> _popularMovies = [];
  List<MediaItem> _popularSeries = [];
  List<MediaItem> _newReleases = [];
  List<MediaItem> _highRatedTitles = [];
  List<MediaItem> _recommendedTitles = [];

  bool _isLoadingHome = false;
  String? _homeErrorMessage;

  List<MediaItem> get popularMovies => _popularMovies;
  List<MediaItem> get popularSeries => _popularSeries;
  List<MediaItem> get newReleases => _newReleases;
  List<MediaItem> get highRatedTitles => _highRatedTitles;
  List<MediaItem> get recommendedTitles => _recommendedTitles;
  
  bool get isLoadingHome => _isLoadingHome;
  String? get homeErrorMessage => _homeErrorMessage;

  Future<void> fetchHomeDashboard() async {
    _isLoadingHome = true;
    _homeErrorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _mediaRepository.getPopularMovies(),
        _mediaRepository.getPopularSeries(),
        _mediaRepository.getNewReleases(),
        _mediaRepository.getHighRatedTitles(),
        _mediaRepository.getRecommendedTitles(),
      ]);

      _popularMovies = results[0];
      _popularSeries = results[1];
      _newReleases = results[2];
      _highRatedTitles = results[3];
      _recommendedTitles = results[4];
      
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