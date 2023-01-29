import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
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

    videoPlayerController.addListener(() {
      if (!videoPlayerController.value.isPlaying) {
        if (mounted) setState(() {});
      }
    });
    videoPlayerController.initialize().then((_) {
      if (mounted) {
        setState(() {
          videoPlayerController.play();
        });
      }
    });
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
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: videoPlayerController.value.isInitialized
                        ? VideoPlayer(videoPlayerController)
                        : CachedNetworkImage(
                            imageUrl: widget.metaData.img ?? "",
                          ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                    child: videoPlayerController.value.isPlaying
                        ? null
                        : const Icon(Icons.play_arrow,
                            size: 140, color: FitnessAppTheme.nearlyWhite),
                  ),
                  onTap: () {
                    setState(() {
                      videoPlayerController.value.isPlaying
                          ? videoPlayerController.pause()
                          : videoPlayerController.play();
                    });
                  },
                ),
              ),
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 16, top: (MediaQuery.of(context).padding.top)),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.arrow_back,
                        size: 30, color: FitnessAppTheme.nearlyWhite),
                  ),
                ),
                onTap: () {
                  if (mounted) videoPlayerController.dispose();
                  AppNavigator.popPage();
                },
              ),

              Positioned(
                  bottom: 150,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                          child: CachedNetworkImage(
                            imageUrl: widget.metaData.avatar ?? "",
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          widget.metaData.name ?? "",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  )),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 140,
                child: Container(
                  color: Colors.black38,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(children: [
                      Expanded(
                        child: Text(widget.metaData.title ?? "",
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 17)),
                      ),
                    ]),
                  ),
                ),
              ),

              // SizedBox(
              //   height: MediaQuery.of(context).padding.bottom,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
