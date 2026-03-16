import 'dart:io';
import 'package:path_provider/path_provider.dart';

String _sanitizeFileName(String input) {
  return input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
}

Future<String?> prepareLocalVideoPath(String videoUrl) async {
  final dir = await getApplicationDocumentsDirectory();
  final offlineDir = Directory('${dir.path}/offline_videos');
  if (!await offlineDir.exists()) {
    await offlineDir.create(recursive: true);
  }

  final uri = Uri.tryParse(videoUrl);
  final lastSegment = (uri?.pathSegments.isNotEmpty ?? false)
      ? uri!.pathSegments.last
      : 'video.mp4';
  final rawName = lastSegment.isEmpty ? 'video.mp4' : lastSegment;
  final fileName = _sanitizeFileName(rawName.contains('.') ? rawName : '$rawName.mp4');
  return '${offlineDir.path}/$fileName';
}

Future<void> writeFileBytes(String path, List<int> bytes) async {
  final file = File(path);
  await file.writeAsBytes(bytes, flush: true);
}

Future<bool> fileExists(String path) async {
  return File(path).exists();
}

Future<void> deleteFileAt(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}
