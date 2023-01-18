import 'package:chewie/chewie.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String sourceURL;
  const VideoPreviewScreen({super.key, required this.sourceURL});
  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  late Chewie playerWidget;
  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.sourceURL);
    // videoPlayerController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );
    playerWidget = Chewie(controller: chewieController);
  }

  @override
  Widget build(BuildContext context) {
    return playerWidget;
  }
}
