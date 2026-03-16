import 'package:flutter/material.dart';
import '../services/offline_service.dart';
import 'player_screen.dart';

class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  late Future<List<OfflineItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _itemsFuture = OfflineService.getItems();
  }

  Future<void> _refresh() async {
    setState(_reload);
  }

  Future<void> _removeItem(OfflineItem item) async {
    await OfflineService.removeItem(item.videoUrl);
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10151F),
        content: Text('تم حذف ${item.title} من الأوفلاين'),
      ),
    );
  }

  Future<void> _clearAll() async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF0B0E17),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              'حذف كل المحتوى',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'سيتم حذف كل ما حفظته في صفحة الأوفلاين. هل تريد المتابعة؟',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;
    await OfflineService.clearAll();
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF10151F),
        content: Text('تم حذف كل العناصر من الأوفلاين'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060A),
        body: SafeArea(
          child: FutureBuilder<List<OfflineItem>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <OfflineItem>[];

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10141D), Color(0xFF0B0E17)],
                              ),
                              border: Border.all(color: const Color(0xFF1B2133)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3BA4E).withOpacity(.12),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.download_done_rounded,
                                    color: Color(0xFFE3BA4E),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'المشاهدة بدون إنترنت',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${items.length} عنصر محفوظ عندك الآن',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (items.isNotEmpty)
                                  IconButton(
                                    onPressed: _clearAll,
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Colors.redAccent.withOpacity(.12),
                                      foregroundColor: Colors.redAccent,
                                    ),
                                    icon: const Icon(Icons.delete_sweep_rounded),
                                  ),
                              ],
                            ),
                          ),
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFE3BA4E),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (snapshot.connectionState != ConnectionState.waiting)
                    items.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 94,
                                      height: 94,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B0E17),
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: const Color(0xFF1B2133),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.cloud_download_outlined,
                                        color: Color(0xFFE3BA4E),
                                        size: 42,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    const Text(
                                      'ما عندك شيء محفوظ حاليًا',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'لما تضيف أفلام أو حلقات للأوفلاين رح تظهر هنا بشكل مرتب وسهل.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                            sliver: SliverList.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _OfflineCard(
                                    item: item,
                                    onPlay: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PlayerScreen(
                                            title: item.title,
                                            videoUrl: item.videoUrl,
                                            image: item.image,
                                            type: item.type,
                                            localFilePath: item.localPath,
                                          ),
                                        ),
                                      );
                                    },
                                    onDelete: () => _removeItem(item),
                                  ),
                                );
                              },
                            ),
                          ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  final OfflineItem item;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _OfflineCard({
    required this.item,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E17),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1B2133)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPlay,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 92,
                  height: 120,
                  child: Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF121826),
                      child: const Icon(Icons.movie_rounded,
                          color: Colors.white54, size: 30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3BA4E).withOpacity(.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.type,
                            style: const TextStyle(
                              color: Color(0xFFE3BA4E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.isDownloaded ? const Color(0xFF17361F) : const Color(0xFF1A2233),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.isDownloaded ? 'محفوظ' : 'قائمة فقط',
                            style: TextStyle(
                              color: item.isDownloaded ? const Color(0xFF7DFF9B) : Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE3BA4E),
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: onPlay,
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('تشغيل'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onDelete,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white70,
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
