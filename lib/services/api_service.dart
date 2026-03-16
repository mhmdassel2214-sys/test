import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieItem {
  final String id;
  final String title;
  final String image;
  final String category;
  final String rating;
  final String videoUrl;
  final bool isNew;
  final bool isTop;
  final bool isFeatured;
  final String date;
  final String badge;
  final String description;

  MovieItem({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.rating,
    required this.videoUrl,
    required this.isNew,
    required this.isTop,
    required this.isFeatured,
    required this.date,
    required this.badge,
    required this.description,
  });

  factory MovieItem.fromJson(Map<String, dynamic> json) {
    return MovieItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      rating: json['rating']?.toString() ?? '',
      videoUrl: json['videoUrl'] ?? '',
      isNew: json['isNew'] ?? false,
      isTop: json['isTop'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      date: json['date'] ?? '',
      badge: json['badge'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class EpisodeItem {
  final String title;
  final String videoUrl;

  EpisodeItem({
    required this.title,
    required this.videoUrl,
  });

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}

class SeriesItem {
  final String id;
  final String title;
  final String image;
  final String category;
  final String rating;
  final bool isNew;
  final bool isTop;
  final bool isFeatured;
  final String date;
  final String badge;
  final String description;
  final List<EpisodeItem> episodes;

  SeriesItem({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.rating,
    required this.isNew,
    required this.isTop,
    required this.isFeatured,
    required this.date,
    required this.badge,
    required this.description,
    required this.episodes,
  });

  factory SeriesItem.fromJson(Map<String, dynamic> json) {
    return SeriesItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      rating: json['rating']?.toString() ?? '',
      isNew: json['isNew'] ?? false,
      isTop: json['isTop'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      date: json['date'] ?? '',
      badge: json['badge'] ?? '',
      description: json['description'] ?? '',
      episodes: (json['episodes'] as List? ?? [])
          .map((e) => EpisodeItem.fromJson(e))
          .toList(),
    );
  }
}

class LiveChannel {
  final String title;
  final String url;
  final String category;
  final String image;

  LiveChannel({
    required this.title,
    required this.url,
    required this.category,
    required this.image,
  });

  factory LiveChannel.fromJson(Map<String, dynamic> json) {
    return LiveChannel(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class ApiService {
  static const String moviesUrl = 'https://asmovies-watch.pages.dev/movies.json';
  static const String seriesUrl = 'https://asmovies-watch.pages.dev/series.json';
  static const String liveUrl = 'https://asmovies-watch.pages.dev/live.json';

  static Future<List<MovieItem>> fetchMovies() async {
    final response = await http.get(Uri.parse(moviesUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['movies'] as List? ?? [];
      return list.map((e) => MovieItem.fromJson(e)).toList();
    }
    throw Exception('فشل تحميل الأفلام');
  }

  static Future<List<SeriesItem>> fetchSeries() async {
    final response = await http.get(Uri.parse(seriesUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['series'] as List? ?? [];
      return list.map((e) => SeriesItem.fromJson(e)).toList();
    }
    throw Exception('فشل تحميل المسلسلات');
  }

  static Future<List<LiveChannel>> fetchLiveChannels() async {
    final response = await http.get(Uri.parse(liveUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['channels'] as List? ?? [];
      return list.map((e) => LiveChannel.fromJson(e)).toList();
    }
    throw Exception('فشل تحميل البث المباشر');
  }
}
