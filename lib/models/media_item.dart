import 'enums.dart';

class MediaItem {
  final String id;
  final String imdbId;
  final String title;
  final String year;
  final String poster;
  final MediaType type;
  final String plot;
  final String director;
  final String genre;
  final String runtime;
  final String imdbRating;
  final int totalSeasons;
  final String actors;
  final int totalEpisodes;
  final String status;

  MediaItem({
    required this.id,
    required this.imdbId,
    required this.title,
    required this.year,
    required this.poster,
    required this.type,
    required this.plot,
    required this.director,
    required this.genre,
    required this.runtime,
    required this.imdbRating,
    required this.totalSeasons,
    this.actors = 'N/A',
    this.totalEpisodes = 0,
    this.status = 'Unknown',
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    // Helper to derive status from the year string (e.g., "2005–" means Continuing)
    String deriveStatus(String yearStr) {
      if (yearStr.endsWith('–') || yearStr.endsWith('-')) return 'Continuing';
      if (yearStr.contains('–') || yearStr.contains('-')) return 'Ended';
      return 'Released';
    }

    return MediaItem(
      id: json['_id'] ?? json['id'] ?? '',
      imdbId: json['imdbID'] ?? json['imdbId'] ?? '',
      title: json['Title'] ?? json['title'] ?? 'Unknown',
      year: json['Year'] ?? json['year'] ?? '',
      poster: json['Poster'] ?? json['poster'] ?? '',
      type: (json['Type'] ?? json['type']).toString().toLowerCase() == 'series' 
          ? MediaType.series 
          : MediaType.movie,
      plot: json['Plot'] ?? json['plot'] ?? 'No plot available.',
      director: json['Director'] ?? json['director'] ?? 'N/A',
      genre: json['Genre'] ?? json['genre'] ?? 'N/A',
      runtime: json['Runtime'] ?? json['runtime'] ?? 'N/A',
      imdbRating: json['imdbRating'] ?? 'N/A',
      totalSeasons: int.tryParse(json['totalSeasons']?.toString() ?? '0') ?? 0,
      
      // --- MAP NEW FIELDS ---
      actors: json['Actors'] ?? json['actors'] ?? 'N/A',
      totalEpisodes: int.tryParse(json['totalEpisodes']?.toString() ?? '0') ?? 0,
      status: json['Status'] ?? json['status'] ?? deriveStatus(json['Year'] ?? json['year'] ?? ''),
    );
  }
}