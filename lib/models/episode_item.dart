class EpisodeItem {
  final String episodeNumber;
  final String seasonNumber;
  final String title;
  final String released;
  final String plot;
  final String runtime;
  final String imdbRating;

  EpisodeItem({
    required this.episodeNumber,
    required this.seasonNumber,
    required this.title,
    required this.released,
    required this.plot,
    required this.runtime,
    required this.imdbRating,
  });

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      episodeNumber: json['Episode']?.toString() ?? json['episodeNumber']?.toString() ?? '1',
      seasonNumber: json['Season']?.toString() ?? json['seasonNumber']?.toString() ?? '1',
      title: json['Title'] ?? json['title'] ?? 'Unknown Episode',
      released: json['Released'] ?? json['released'] ?? 'N/A',
      plot: json['Plot'] ?? json['plot'] ?? 'No description available for this episode.',
      runtime: json['Runtime'] ?? json['runtime'] ?? 'N/A',
      // FIX: Removed duplicate json key check
      imdbRating: json['imdbRating'] ?? 'N/A',
    );
  }
}