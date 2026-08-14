import 'package:flutter/material.dart';
import '../models/comment_item.dart';
import '../models/user_stats.dart';
import '../repositories/activity_repository.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _activityRepository;

  ActivityProvider({ActivityRepository? activityRepository})
      : _activityRepository = activityRepository ?? ActivityRepository();

  Map<String, dynamic> _currentActivity = {};
  List<CommentItem> _comments = [];
  UserStats? _userStats;
  bool _isLoading = false;

  Map<String, dynamic> get currentActivity => _currentActivity;
  List<CommentItem> get comments => _comments;
  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;

  Future<void> fetchMediaActivity(String imdbId) async {
    _isLoading = true;
    notifyListeners();

    _currentActivity = await _activityRepository.getActivity(imdbId);
    _comments = await _activityRepository.getComments(imdbId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateWatchStatus(String imdbId, String status) async {
    _currentActivity['watchStatus'] = status;
    notifyListeners();
    await _activityRepository.updateActivity(imdbId: imdbId, watchStatus: status);
  }

  Future<void> updateRating(String imdbId, int rating) async {
    _currentActivity['rating'] = rating;
    notifyListeners();
    await _activityRepository.updateActivity(imdbId: imdbId, rating: rating);
  }

  Future<void> toggleFavorite(String imdbId) async {
    final current = _currentActivity['isFavorite'] ?? false;
    _currentActivity['isFavorite'] = !current;
    notifyListeners();
    await _activityRepository.updateActivity(imdbId: imdbId, isFavorite: !current);
  }

  Future<void> updateWatchedEpisodes(String imdbId, List<String> episodes) async {
    _currentActivity['watchedEpisodes'] = episodes;
    notifyListeners();
    await _activityRepository.updateActivity(imdbId: imdbId, watchedEpisodes: episodes);
  }

  Future<void> postComment(String imdbId, String text, bool hasSpoiler) async {
    final newComment = await _activityRepository.addComment(imdbId, text, hasSpoiler);
    _comments.insert(0, newComment);
    notifyListeners();
  }

  Future<void> fetchUserStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userStats = await _activityRepository.getUserStats();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}