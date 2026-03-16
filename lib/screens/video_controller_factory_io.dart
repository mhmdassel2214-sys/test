import 'dart:io';
import 'package:video_player/video_player.dart';

VideoPlayerController buildVideoController(String videoUrl, {String? localFilePath}) {
  if (localFilePath != null && localFilePath.isNotEmpty) {
    final file = File(localFilePath);
    if (file.existsSync()) {
      return VideoPlayerController.file(file);
    }
  }
  return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
}
