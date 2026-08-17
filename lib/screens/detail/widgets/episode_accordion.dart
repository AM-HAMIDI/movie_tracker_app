import 'package:flutter/material.dart';
import '../../../repositories/media_repository.dart';
import '../../../models/episode_item.dart'; // <-- Added import for your model

class EpisodeAccordion extends StatefulWidget {
  final String imdbId;
  final int totalSeasons;
  final List<String> watchedEpisodes;
  final Function(List<String>) onWatchedChanged;

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
  final MediaRepository _mediaRepo = MediaRepository();
  
  // FIX: Changed from List<dynamic> to List<EpisodeItem> to use your model
  final Map<int, List<EpisodeItem>> _seasonEpisodes = {}; 
  final Map<int, bool> _loadingSeasons = {};
  final List<bool> _expandedSeasons = [];

  @override
  void initState() {
    super.initState();
    _expandedSeasons.addAll(List.generate(widget.totalSeasons, (_) => false));
  }

  Future<void> _fetchSeasonData(int seasonNum) async {
    if (_seasonEpisodes.containsKey(seasonNum) || (_loadingSeasons[seasonNum] ?? false)) {
      return;
    }

    setState(() {
      _loadingSeasons[seasonNum] = true;
    });

    try {
      // FIX: Using getSeasonEpisodes to map directly to your EpisodeItem models
      final episodes = await _mediaRepo.getSeasonEpisodes(widget.imdbId, seasonNum);
      if (mounted) {
        setState(() {
          _seasonEpisodes[seasonNum] = episodes;
          _loadingSeasons[seasonNum] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSeasons[seasonNum] = false;
        });
      }
      debugPrint('Error loading season $seasonNum: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalSeasons <= 0) {
      return const Text('No seasons information available.', style: TextStyle(color: Colors.white54));
    }

    return Theme(
      data: Theme.of(context).copyWith(cardColor: const Color(0xFF1E1E1E)),
      child: ExpansionPanelList(
        elevation: 1,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _expandedSeasons[index] = !_expandedSeasons[index];
          });
          
          if (_expandedSeasons[index]) {
            _fetchSeasonData(index + 1);
          }
        },
        children: List.generate(widget.totalSeasons, (index) {
          final seasonNum = index + 1;
          final isExpanded = _expandedSeasons[index];
          final isLoading = _loadingSeasons[seasonNum] ?? false;
          final episodes = _seasonEpisodes[seasonNum] ?? [];

          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  'Season $seasonNum',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              );
            },
            body: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : episodes.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No episodes found for this season.', style: TextStyle(color: Colors.white54)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: episodes.length,
                        itemBuilder: (context, epIndex) {
                          // FIX: Extracting data from the EpisodeItem object safely
                          final ep = episodes[epIndex];
                          final epNumber = ep.episodeNumber;
                          final epTitle = ep.title;
                          
                          // Omitting the plot text if it's the default OMDb fallback to keep the UI clean
                          final bool hasPlot = ep.plot != 'No description available for this episode.' && ep.plot != 'N/A';
                          final epReleased = ep.released;
                          
                          final episodeKey = 'S${seasonNum}E$epNumber';
                          final isWatched = widget.watchedEpisodes.contains(episodeKey);

                          return CheckboxListTile(
                            title: Text('$epNumber. $epTitle', style: const TextStyle(color: Colors.white, fontSize: 14)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Released: $epReleased', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                if (hasPlot) ...[
                                  const SizedBox(height: 2),
                                  Text(ep.plot, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ],
                            ),
                            value: isWatched,
                            activeColor: Colors.deepPurpleAccent,
                            onChanged: (bool? value) {
                              List<String> updatedList = List.from(widget.watchedEpisodes);
                              if (value == true) {
                                if (!updatedList.contains(episodeKey)) {
                                  updatedList.add(episodeKey);
                                }
                              } else {
                                updatedList.remove(episodeKey);
                              }
                              widget.onWatchedChanged(updatedList);
                            },
                          );
                        },
                      ),
            isExpanded: isExpanded,
            canTapOnHeader: true,
          );
        }),
      ),
    );
  }
}