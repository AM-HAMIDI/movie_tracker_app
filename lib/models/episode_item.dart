class EpisodeItem {
  final int episodeNumber;
  final String title;
  final String released;
  final String rating;

  EpisodeItem({
    required this.episodeNumber,
    required this.title,
    required this.released,
    required this.rating,
  });

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      episodeNumber: json['episodeNumber'] ?? 0,
      title: json['title'] ?? '',
      released: json['released'] ?? '',
      rating: json['rating']?.toString() ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'episodeNumber': episodeNumber,
        'title': title,
        'released': released,
        'rating': rating,
      };
}