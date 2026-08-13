import 'enums.dart';

class MediaItem {
  final String imdbId;
  final String title;
  final MediaType type;
  final String poster;
  final String plot;
  final String genre;
  final String year;
  final String runtime;
  final String director;
  final String actors;
  final String imdbRating;
  final int totalSeasons;

  MediaItem({
    required this.imdbId,
    required this.title,
    required this.type,
    required this.poster,
    required this.plot,
    required this.genre,
    required this.year,
    required this.runtime,
    required this.director,
    required this.actors,
    required this.imdbRating,
    required this.totalSeasons,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      imdbId: json['imdbId'] ?? json['imdbID'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      type: MediaTypeExtension.fromString(json['type'] ?? json['Type']),
      poster: json['poster'] ?? json['Poster'] ?? '',
      plot: json['plot'] ?? json['Plot'] ?? 'No plot overview available.',
      genre: json['genre'] ?? json['Genre'] ?? 'N/A',
      year: json['year'] ?? json['Year'] ?? 'N/A',
      runtime: json['runtime'] ?? json['Runtime'] ?? 'N/A',
      director: json['director'] ?? json['Director'] ?? 'N/A',
      actors: json['actors'] ?? json['Actors'] ?? 'N/A',
      imdbRating: json['imdbRating']?.toString() ?? 'N/A',
      totalSeasons: json['totalSeasons'] is int
          ? json['totalSeasons']
          : int.tryParse(json['totalSeasons']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'imdbId': imdbId,
        'title': title,
        'type': type.toServerString(),
        'poster': poster,
        'plot': plot,
        'genre': genre,
        'year': year,
        'runtime': runtime,
        'director': director,
        'actors': actors,
        'imdbRating': imdbRating,
        'totalSeasons': totalSeasons,
      };
}