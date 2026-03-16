import 'package:flutter/material.dart';
import 'screens/movies_page.dart';
import 'screens/player_screen.dart';
import 'screens/series_details.dart';
import 'screens/series_page.dart';
import 'services/api_service.dart';
import 'services/continue_watching_service.dart';
import 'services/offline_service.dart';
import 'widgets/series_card.dart';
import 'widgets/as_logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<MovieItem>> moviesFuture;
  late Future<List<SeriesItem>> seriesFuture;
  late Future<List<ContinueWatchingItem>> continueWatchingFuture;

  final TextEditingController _searchController = TextEditingController();
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    moviesFuture = ApiService.fetchMovies();
    seriesFuture = ApiService.fetchSeries();
    continueWatchingFuture = ContinueWatchingService.getItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MovieItem> _filterMovies(List<MovieItem> movies) {
    if (searchText.trim().isEmpty) return movies;
    final q = searchText.toLowerCase();
    return movies.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.badge.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();
  }

  List<SeriesItem> _filterSeries(List<SeriesItem> series) {
    if (searchText.trim().isEmpty) return series;
    final q = searchText.toLowerCase();
    return series.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.badge.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q);
    }).toList();
  }

  bool _isRecentlyAdded(String date) {
    if (date.isEmpty) return false;
    try {
      final itemDate = DateTime.parse(date);
      final now = DateTime.now();
      return now.difference(itemDate).inDays <= 1;
    } catch (_) {
      return false;
    }
  }

  List<_MixedPosterItem> _getRecentMixed({
    required List<MovieItem> movies,
    required List<SeriesItem> series,
  }) {
    final items = <_MixedPosterItem>[
      ...movies.map((m) => _MixedPosterItem(
            title: m.title,
            image: m.image,
            date: m.date,
            badge: m.badge,
            isNew: m.isNew,
            onTap: () => _openMovie(m),
          )),
      ...series.map((s) => _MixedPosterItem(
            title: s.title,
            image: s.image,
            date: s.date,
            badge: s.badge,
            isNew: s.isNew,
            onTap: () => _openSeries(s),
          )),
    ];

    items.sort((a, b) {
      try {
        return DateTime.parse(b.date).compareTo(DateTime.parse(a.date));
      } catch (_) {
        return b.date.compareTo(a.date);
      }
    });
    return items.take(10).toList();
  }

  List<SeriesItem> _getFeaturedSeries(List<SeriesItem> series) =>
      series.where((e) => e.isFeatured).toList();

  List<MovieItem> _getFeaturedMovies(List<MovieItem> movies) =>
      movies.where((e) => e.isFeatured).toList();

  List<SeriesItem> _getTopSeries(List<SeriesItem> series) =>
      series.where((e) => e.isTop).toList();

  List<MovieItem> _getTopMovies(List<MovieItem> movies) =>
      movies.where((e) => e.isTop).toList();

  List<SeriesItem> _limitSeries(List<SeriesItem> series, [int count = 10]) =>
      series.take(count).toList();

  List<MovieItem> _limitMovies(List<MovieItem> movies, [int count = 10]) =>
      movies.take(count).toList();

  void _openSeries(SeriesItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SeriesDetailsPage(series: item)),
    ).then((_) {
      if (mounted) {
        setState(() {
          continueWatchingFuture = ContinueWatchingService.getItems();
        });
      }
    });
  }

  Future<void> _saveOffline({
    required String title,
    required String image,
    required String videoUrl,
    required String type,
  }) async {
    final result = await OfflineService.addItem(
      OfflineItem(title: title, image: image, videoUrl: videoUrl, type: type),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }

  void _openMovie(MovieItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  item.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    width: double.infinity,
                    color: const Color(0xFF111827),
                    child: const Icon(Icons.movie, color: Colors.white54, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.category} · تقييم ${item.rating}',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _saveOffline(
                          title: item.title,
                          image: item.image,
                          videoUrl: item.videoUrl,
                          type: 'فيلم',
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('تنزيل أوفلاين', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2E3648)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(
                              title: item.title,
                              videoUrl: item.videoUrl,
                              image: item.image,
                              type: 'فيلم',
                            ),
                          ),
                        );
                        if (!mounted) return;
                        setState(() {
                          continueWatchingFuture = ContinueWatchingService.getItems();
                        });
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('تشغيل', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5B13E),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshData() async {
    setState(_loadData);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060A),
        body: SafeArea(
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([seriesFuture, moviesFuture, continueWatchingFuture]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFD5B13E)));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'صار خطأ في تحميل البيانات\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              final series = _filterSeries(snapshot.data![0] as List<SeriesItem>);
              final movies = _filterMovies(snapshot.data![1] as List<MovieItem>);
              final continueWatching = snapshot.data![2] as List<ContinueWatchingItem>;

              final featuredSeries = _getFeaturedSeries(series);
              final featuredMovies = _getFeaturedMovies(movies);
              final topSeries = _getTopSeries(series);
              final topMovies = _getTopMovies(movies);
              final recentItems = _getRecentMixed(movies: movies, series: series);
              final homeSeries = _limitSeries(series, 10);
              final homeMovies = _limitMovies(movies, 10);

              final topItems = <_MixedPosterItem>[
                ...topSeries.map((e) => _MixedPosterItem(
                      title: e.title,
                      image: e.image,
                      date: e.date,
                      badge: e.badge,
                      isNew: e.isNew,
                      onTap: () => _openSeries(e),
                    )),
                ...topMovies.map((e) => _MixedPosterItem(
                      title: e.title,
                      image: e.image,
                      date: e.date,
                      badge: e.badge,
                      isNew: e.isNew,
                      onTap: () => _openMovie(e),
                    )),
              ];

              return RefreshIndicator(
                color: const Color(0xFFD5B13E),
                backgroundColor: const Color(0xFF0B0E17),
                onRefresh: _refreshData,
                child: ListView(
                  cacheExtent: 1000,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 40),
                  children: [
                    const _HeaderBar(),
                    const SizedBox(height: 16),
                    _SearchBar(
                      controller: _searchController,
                      onChanged: (value) => setState(() => searchText = value),
                    ),
                    const SizedBox(height: 18),
                    if (featuredSeries.isNotEmpty)
                      _HeroBanner(
                        title: featuredSeries.first.title,
                        image: featuredSeries.first.image,
                        subtitle: featuredSeries.first.description.isNotEmpty
                            ? featuredSeries.first.description
                            : 'أحدث الحلقات متوفرة الآن بجودة ممتازة',
                        tag: featuredSeries.first.badge.isNotEmpty ? featuredSeries.first.badge : 'حصري',
                        onPlay: () => _openSeries(featuredSeries.first),
                      )
                    else if (featuredMovies.isNotEmpty)
                      _HeroBanner(
                        title: featuredMovies.first.title,
                        image: featuredMovies.first.image,
                        subtitle: featuredMovies.first.description.isNotEmpty
                            ? featuredMovies.first.description
                            : '${featuredMovies.first.category} · تقييم ${featuredMovies.first.rating}',
                        tag: featuredMovies.first.badge.isNotEmpty ? featuredMovies.first.badge : 'مميز',
                        onPlay: () => _openMovie(featuredMovies.first),
                      )
                    else if (series.isNotEmpty)
                      _HeroBanner(
                        title: series.first.title,
                        image: series.first.image,
                        subtitle: series.first.description.isNotEmpty
                            ? series.first.description
                            : 'أحدث الحلقات متوفرة الآن',
                        tag: series.first.badge.isNotEmpty ? series.first.badge : 'HD',
                        onPlay: () => _openSeries(series.first),
                      )
                    else if (movies.isNotEmpty)
                      _HeroBanner(
                        title: movies.first.title,
                        image: movies.first.image,
                        subtitle: movies.first.description.isNotEmpty
                            ? movies.first.description
                            : '${movies.first.category} · تقييم ${movies.first.rating}',
                        tag: movies.first.badge.isNotEmpty ? movies.first.badge : 'HD',
                        onPlay: () => _openMovie(movies.first),
                      ),
                    const SizedBox(height: 24),
                    if (continueWatching.isNotEmpty) ...[
                      const _SectionHeader(title: 'أكمل المشاهدة', actionText: ''),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemCount: continueWatching.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final item = continueWatching[i];
                            final progress = item.durationSeconds > 0
                                ? item.positionSeconds / item.durationSeconds
                                : 0.0;
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                      title: item.title,
                                      videoUrl: item.videoUrl,
                                      image: item.image,
                                      type: item.type,
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                setState(() {
                                  continueWatchingFuture = ContinueWatchingService.getItems();
                                });
                              },
                              child: _ContinueWatchingCard(item: item, progress: progress),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 26),
                    ],
                    if (recentItems.isNotEmpty) ...[
                      const _SectionHeader(title: 'المضاف حديثًا', actionText: 'اسحب'),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemCount: recentItems.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final item = recentItems[i];
                            return GestureDetector(
                              onTap: item.onTap,
                              child: _RecentPosterCard(
                                title: item.title,
                                image: item.image,
                                showNewBadge: item.isNew || _isRecentlyAdded(item.date),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 26),
                    ],
                    if (topItems.isNotEmpty) ...[
                      const _SectionHeader(title: 'الأكثر مشاهدة', actionText: ''),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemCount: topItems.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final item = topItems[i];
                            return GestureDetector(
                              onTap: item.onTap,
                              child: _RecentPosterCard(
                                title: item.title,
                                image: item.image,
                                showNewBadge: item.isNew,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 26),
                    ],
                    if (series.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'المسلسلات',
                        actionText: 'عرض الكل',
                        onActionTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SeriesPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 320,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemCount: homeSeries.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (_, i) {
                            final item = homeSeries[i];
                            return SizedBox(
                              width: 180,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () => _openSeries(item),
                                    child: SeriesCard(series: item),
                                  ),
                                  if (item.isNew || _isRecentlyAdded(item.date))
                                    const Positioned(
                                      top: 8,
                                      left: 8,
                                      child: _SmallBadge(
                                        text: 'جديد',
                                        color: Colors.redAccent,
                                        textColor: Colors.white,
                                      ),
                                    ),
                                  if (item.badge.isNotEmpty)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: _SmallBadge(
                                        text: item.badge,
                                        color: const Color(0xFFD5B13E),
                                        textColor: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 26),
                    ],
                    if (movies.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'الأفلام',
                        actionText: 'عرض الكل',
                        onActionTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MoviesPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 320,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          itemCount: homeMovies.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (_, i) {
                            final item = homeMovies[i];
                            return SizedBox(
                              width: 180,
                              child: _MoviePosterCard(
                                title: item.title,
                                subtitle: '${item.category} · تقييم ${item.rating}',
                                image: item.image,
                                showNewBadge: item.isNew || _isRecentlyAdded(item.date),
                                badge: item.badge,
                                onTap: () => _openMovie(item),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 26),
                    ],
                    if (series.isEmpty && movies.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(
                          child: Text(
                            'لا توجد نتائج',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MixedPosterItem {
  final String title;
  final String image;
  final String date;
  final String badge;
  final bool isNew;
  final VoidCallback onTap;

  _MixedPosterItem({
    required this.title,
    required this.image,
    required this.date,
    required this.badge,
    required this.isNew,
    required this.onTap,
  });
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AsLogo(
          size: 46,
          glow: false,
          compact: true,
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AsMovies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            SizedBox(height: 3),
            Text('أفلام ومسلسلات', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1018),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1A2233)),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1018),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1A2233)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.right,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'ابحث عن فيلم أو مسلسل...',
          hintStyle: TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String title;
  final String image;
  final String subtitle;
  final String tag;
  final VoidCallback onPlay;

  const _HeroBanner({
    required this.title,
    required this.image,
    required this.subtitle,
    required this.tag,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 235,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF111827),
                  child: const Icon(Icons.movie, color: Colors.white54, size: 40),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.black.withOpacity(.10),
                      Colors.black.withOpacity(.28),
                      Colors.black.withOpacity(.86),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _SmallBadge(
                      text: tag,
                      color: const Color(0xFFD5B13E),
                      textColor: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPlay,
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('شاهد الآن', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD5B13E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({required this.title, required this.actionText, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF0D1018),
                border: Border.all(color: const Color(0xFF1B2130)),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        const Spacer(),
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFD5B13E),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 19),
        ),
      ],
    );
  }
}

class _RecentPosterCard extends StatelessWidget {
  final String title;
  final String image;
  final bool showNewBadge;

  const _RecentPosterCard({required this.title, required this.image, required this.showNewBadge});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E17),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF1A2030)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.25),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF111827),
                          child: const Icon(Icons.movie, color: Colors.white54),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(.6)],
                        ),
                      ),
                    ),
                  ),
                  if (showNewBadge)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: _SmallBadge(text: 'جديد', color: Colors.redAccent, textColor: Colors.white),
                    ),
                  const Positioned(
                    bottom: 10,
                    right: 10,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFD5B13E),
                      child: Icon(Icons.play_arrow_rounded, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ContinueWatchingCard extends StatelessWidget {
  final ContinueWatchingItem item;
  final double progress;

  const _ContinueWatchingCard({required this.item, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B0E17),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF1A2030)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: item.image.isNotEmpty
                          ? Image.network(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF111827),
                                child: const Icon(Icons.play_circle_outline, color: Colors.white54, size: 40),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF111827),
                              child: const Icon(Icons.play_circle_outline, color: Colors.white54, size: 40),
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(.65)],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 12,
                    right: 12,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFD5B13E),
                      child: Icon(Icons.play_arrow_rounded, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFD5B13E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoviePosterCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool showNewBadge;
  final String badge;
  final VoidCallback onTap;

  const _MoviePosterCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.showNewBadge,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1B2133)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF111827),
                        child: const Icon(Icons.movie, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(.55)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _SmallBadge(
                    text: badge.isNotEmpty ? badge : 'HD',
                    color: const Color(0xFFD5B13E),
                    textColor: Colors.black,
                  ),
                ),
                if (showNewBadge)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: _SmallBadge(text: 'جديد', color: Colors.redAccent, textColor: Colors.white),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('مشاهدة', style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFD5B13E),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _SmallBadge({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}
