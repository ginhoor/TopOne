import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  final TTResult metaData;
  final String? localFilePath;
  const VideoPreviewScreen(
      {super.key, required this.metaData, this.localFilePath});
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
    var localFilePath = widget.localFilePath;
    if (localFilePath != null) {
      var file = File(localFilePath);
      videoPlayerController = VideoPlayerController.file(file);
    } else if (widget.metaData.video != null) {
      videoPlayerController =
          VideoPlayerController.network(widget.metaData.video!);
    } else {
      videoPlayerController = VideoPlayerController.asset("");
    }
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );
    playerWidget = Chewie(controller: chewieController);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: Stack(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              playerWidget,
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ),
      ),
    );
  }
}
