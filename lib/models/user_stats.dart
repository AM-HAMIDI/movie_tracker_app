class UserStats {
  final int watchedMovies;
  final int watchedSeries;
  final int totalEpisodes;
  final int totalWatchTimeMinutes;
  final String favoriteGenre;
  final double averageRating;

  UserStats({
    required this.watchedMovies,
    required this.watchedSeries,
    required this.totalEpisodes,
    required this.totalWatchTimeMinutes,
    required this.favoriteGenre,
    required this.averageRating,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      watchedMovies: json['watchedMovies'] ?? 0,
      watchedSeries: json['watchedSeries'] ?? 0,
      totalEpisodes: json['totalEpisodes'] ?? 0,
      totalWatchTimeMinutes: json['totalWatchTimeMinutes'] ?? 0,
      favoriteGenre: json['favoriteGenre'] ?? 'N/A',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'watchedMovies': watchedMovies,
        'watchedSeries': watchedSeries,
        'totalEpisodes': totalEpisodes,
        'totalWatchTimeMinutes': totalWatchTimeMinutes,
        'favoriteGenre': favoriteGenre,
        'averageRating': averageRating,
      };
}