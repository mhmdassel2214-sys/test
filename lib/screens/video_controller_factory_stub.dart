import 'package:video_player/video_player.dart';

VideoPlayerController buildVideoController(String videoUrl, {String? localFilePath}) {
  return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
}
