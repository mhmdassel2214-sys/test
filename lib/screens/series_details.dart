import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import 'player_screen.dart';

class SeriesDetailsPage extends StatelessWidget {
  final SeriesItem series;

  const SeriesDetailsPage({super.key, required this.series});

  Future<void> _saveEpisodeOffline(
    BuildContext context,
    EpisodeItem episode,
  ) async {
    final result = await OfflineService.addItem(
      OfflineItem(
        title: '${series.title} - ${episode.title}',
        image: series.image,
        videoUrl: episode.videoUrl,
        type: 'حلقة',
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }

  void _openEpisode(
    BuildContext context,
    EpisodeItem episode,
    int index,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          title: '${series.title} - ${episode.title}',
          videoUrl: episode.videoUrl,
          image: series.image,
          type: 'حلقة',
          episodes: series.episodes,
          currentIndex: index,
          seriesTitle: series.title,
        ),
      ),
    );
  }

  void _playFirstEpisode(BuildContext context) {
    if (series.episodes.isEmpty) return;
    _openEpisode(context, series.episodes.first, 0);
  }

  @override
  Widget build(BuildContext context) {
    final episodes = series.episodes;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060A),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: const Color(0xFF05060A),
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      series.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF111827),
                        child: const Icon(
                          Icons.live_tv_rounded,
                          color: Colors.white54,
                          size: 54,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(.05),
                            Colors.black.withOpacity(.2),
                            const Color(0xFF05060A),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.star_rounded,
                          text: 'تقييم ${series.rating}',
                        ),
                        _MetaChip(
                          icon: Icons.live_tv_rounded,
                          text: '${episodes.length} حلقة',
                        ),
                        if (series.category.trim().isNotEmpty)
                          _MetaChip(
                            icon: Icons.category_rounded,
                            text: series.category,
                          ),
                        _MetaChip(
                          icon: Icons.high_quality_rounded,
                          text: series.badge.isNotEmpty ? series.badge : 'HD',
                        ),
                      ],
                    ),
                    if (series.description.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        series.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (episodes.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _playFirstEpisode(context),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(
                            'مشاهدة الحلقة الأولى',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD5B13E),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    const Text(
                      'الحلقات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: episodes.length,
                itemBuilder: (context, index) {
                  final episode = episodes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0E17),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1B2133)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFD5B13E),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        title: Text(
                          episode.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          'اضغط للمشاهدة أو التنزيل',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.55),
                            fontSize: 12,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 108,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _saveEpisodeOffline(context, episode),
                                icon: const Icon(
                                  Icons.download_rounded,
                                  color: Colors.white70,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _openEpisode(context, episode, index),
                                icon: const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Color(0xFFD5B13E),
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1018),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B2133)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD5B13E)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
