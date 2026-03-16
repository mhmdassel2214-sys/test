import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'file_storage.dart';

class OfflineItem {
  final String title;
  final String image;
  final String videoUrl;
  final String type;
  final String localPath;

  const OfflineItem({
    required this.title,
    required this.image,
    required this.videoUrl,
    required this.type,
    this.localPath = '',
  });

  bool get isDownloaded => localPath.isNotEmpty;

  OfflineItem copyWith({
    String? title,
    String? image,
    String? videoUrl,
    String? type,
    String? localPath,
  }) {
    return OfflineItem(
      title: title ?? this.title,
      image: image ?? this.image,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'image': image,
        'videoUrl': videoUrl,
        'type': type,
        'localPath': localPath,
      };

  factory OfflineItem.fromJson(Map<String, dynamic> json) {
    return OfflineItem(
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      type: json['type'] ?? '',
      localPath: json['localPath'] ?? '',
    );
  }
}

class OfflineSaveResult {
  final OfflineItem item;
  final bool downloaded;
  final String message;

  const OfflineSaveResult({
    required this.item,
    required this.downloaded,
    required this.message,
  });
}

class OfflineService {
  static const String _key = 'offline_items';

  static bool _looksDownloadable(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith('http') &&
        !lower.contains('.m3u8') &&
        !lower.contains('youtube.com') &&
        !lower.contains('youtu.be');
  }

  static Future<void> _writeItems(List<OfflineItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<OfflineItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List;
    final items = decoded
        .map((e) => OfflineItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    bool changed = false;
    final checked = <OfflineItem>[];
    for (final item in items) {
      if (item.localPath.isNotEmpty) {
        final exists = await fileExists(item.localPath);
        if (!exists) {
          checked.add(item.copyWith(localPath: ''));
          changed = true;
          continue;
        }
      }
      checked.add(item);
    }

    if (changed) {
      await _writeItems(checked);
    }
    return checked;
  }

  static Future<OfflineSaveResult> addItem(OfflineItem item) async {
    final items = await getItems();
    items.removeWhere((e) => e.videoUrl == item.videoUrl);

    if (kIsWeb || !_looksDownloadable(item.videoUrl)) {
      final queueItem = item.copyWith(localPath: '');
      items.insert(0, queueItem);
      await _writeItems(items);
      return OfflineSaveResult(
        item: queueItem,
        downloaded: false,
        message: kIsWeb
            ? 'تمت الإضافة للقائمة فقط. التحميل الحقيقي يعمل على أندرويد أو ويندوز.'
            : 'تمت الإضافة للقائمة فقط. الروابط من نوع m3u8 أو الروابط غير المباشرة لا تُحمّل كأوفلاين كامل.',
      );
    }

    try {
      final response = await http.get(Uri.parse(item.videoUrl));
      if (response.statusCode < 200 || response.statusCode >= 300 || response.bodyBytes.isEmpty) {
        final queueItem = item.copyWith(localPath: '');
        items.insert(0, queueItem);
        await _writeItems(items);
        return OfflineSaveResult(
          item: queueItem,
          downloaded: false,
          message: 'تعذر تنزيل الملف، تمت إضافته للقائمة فقط.',
        );
      }

      final path = await prepareLocalVideoPath(item.videoUrl);
      if (path == null || path.isEmpty) {
        final queueItem = item.copyWith(localPath: '');
        items.insert(0, queueItem);
        await _writeItems(items);
        return OfflineSaveResult(
          item: queueItem,
          downloaded: false,
          message: 'تمت الإضافة للقائمة فقط.',
        );
      }

      await writeFileBytes(path, response.bodyBytes);
      final saved = item.copyWith(localPath: path);
      items.insert(0, saved);
      await _writeItems(items);
      return OfflineSaveResult(
        item: saved,
        downloaded: true,
        message: 'تم تنزيل الملف وحفظه للأوفلاين.',
      );
    } catch (_) {
      final queueItem = item.copyWith(localPath: '');
      items.insert(0, queueItem);
      await _writeItems(items);
      return OfflineSaveResult(
        item: queueItem,
        downloaded: false,
        message: 'صار خطأ بالتنزيل، تمت الإضافة للقائمة فقط.',
      );
    }
  }

  static Future<void> removeItem(String videoUrl) async {
    final items = await getItems();
    final toRemove = items.where((e) => e.videoUrl == videoUrl).toList();
    for (final item in toRemove) {
      if (item.localPath.isNotEmpty) {
        await deleteFileAt(item.localPath);
      }
    }
    items.removeWhere((e) => e.videoUrl == videoUrl);
    await _writeItems(items);
  }

  static Future<void> clearAll() async {
    final items = await getItems();
    for (final item in items) {
      if (item.localPath.isNotEmpty) {
        await deleteFileAt(item.localPath);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
