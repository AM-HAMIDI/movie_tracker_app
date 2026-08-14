import 'package:flutter/material.dart';
import '../../../models/episode_item.dart';
import '../../../repositories/media_repository.dart';

class EpisodeAccordion extends StatefulWidget {
  final String imdbId;
  final int totalSeasons;
  final List<String> watchedEpisodes;
  final ValueChanged<List<String>> onWatchedChanged;

  const EpisodeAccordion({
    super.key,
    required this.imdbId,
    required this.totalSeasons,
    required this.watchedEpisodes,
    required this.onWatchedChanged,
  });

  @override
  State<EpisodeAccordion> createState() => _EpisodeAccordionState();
}

class _EpisodeAccordionState extends State<EpisodeAccordion> {
  final _mediaRepo = MediaRepository();
  int? _expandedSeason;
  final Map<int, List<EpisodeItem>> _seasonData = {};
  final Map<int, bool> _loadingMap = {};

  void _loadSeason(int seasonNum) async {
    if (_seasonData.containsKey(seasonNum)) return;
    setState(() => _loadingMap[seasonNum] = true);

    try {
      final episodes = await _mediaRepo.getSeasonEpisodes(widget.imdbId, seasonNum);
      setState(() {
        _seasonData[seasonNum] = episodes;
        _loadingMap[seasonNum] = false;
      });
    } catch (_) {
      setState(() => _loadingMap[seasonNum] = false);
    }
  }

  void _toggleEpisode(String code) {
    final updated = List<String>.from(widget.watchedEpisodes);
    if (updated.contains(code)) {
      updated.remove(code);
    } else {
      updated.add(code);
    }
    widget.onWatchedChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      initialOpenPanelValue: _expandedSeason,
      children: List.generate(widget.totalSeasons, (index) {
        final seasonNum = index + 1;
        final episodes = _seasonData[seasonNum] ?? [];
        final isLoading = _loadingMap[seasonNum] ?? false;

        return ExpansionPanelRadio(
          value: seasonNum,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            if (isExpanded) _loadSeason(seasonNum);
            return ListTile(
              title: Text('Season $seasonNum', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                episodes.isNotEmpty ? '${episodes.length} Episodes' : 'Tap to expand',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            );
          },
          body: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  children: episodes.map((ep) {
                    final code = 'S${seasonNum}E${ep.episodeNumber}';
                    final isChecked = widget.watchedEpisodes.contains(code);
                    return CheckboxListTile(
                      value: isChecked,
                      activeColor: Colors.deepPurpleAccent,
                      title: Text('Ep ${ep.episodeNumber}: ${ep.title}'),
                      subtitle: Text(
                        'Aired: ${ep.released} • Rating: ${ep.rating} ⭐',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      onChanged: (_) => _toggleEpisode(code),
                    );
                  }).toList(),
                ),
        );
      }),
    );
  }
}