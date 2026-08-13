enum WatchStatus {
  planToWatch,
  watching,
  watched,
  onHold,
  dropped,
  favorite,
  none,
}

extension WatchStatusExtension on WatchStatus {
  String toServerString() {
    switch (this) {
      case WatchStatus.planToWatch:
        return 'Plan to Watch';
      case WatchStatus.watching:
        return 'Watching';
      case WatchStatus.watched:
        return 'Watched';
      case WatchStatus.onHold:
        return 'On Hold';
      case WatchStatus.dropped:
        return 'Dropped';
      case WatchStatus.favorite:
        return 'Favorite';
      case WatchStatus.none:
        return 'None';
    }
  }

  static WatchStatus fromString(String? value) {
    switch (value) {
      case 'Plan to Watch':
        return WatchStatus.planToWatch;
      case 'Watching':
        return WatchStatus.watching;
      case 'Watched':
        return WatchStatus.watched;
      case 'On Hold':
        return WatchStatus.onHold;
      case 'Dropped':
        return WatchStatus.dropped;
      case 'Favorite':
        return WatchStatus.favorite;
      default:
        return WatchStatus.none;
    }
  }
}

enum MediaType { movie, series }

extension MediaTypeExtension on MediaType {
  String toServerString() => name;

  static MediaType fromString(String? value) {
    if (value?.toLowerCase() == 'series') {
      return MediaType.series;
    }
    return MediaType.movie;
  }
}