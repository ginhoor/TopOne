import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gh_tool_package/log/logger.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/photo_library_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/tool/store_kit.dart';
import 'package:top_one/view/dialog.dart';
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
  double progressValue = 0; //进度
  String labelProgress = ""; //tip内容

  bool playEnd = false;
  @override
  void dispose() {
    ADService().videoPlayINTAdService.show((p0) => null);
    videoPlayerController.removeListener(listen);
    super.dispose();
  }

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
    progressValue = 0.0;
    labelProgress = '00:00';
    videoPlayerController.addListener(listen);
    videoPlayerController.initialize().then((_) {
      if (mounted) {
        setState(() {
          videoPlayerController.play();
        });
        showRateDialog(context);
      }
    });
  }

  void listen() {
    if (!videoPlayerController.value.isPlaying) {
      if (mounted) setState(() {});
    } else {
      playEnd = false;
    }
    int position = videoPlayerController.value.position.inMilliseconds;
    int duration = videoPlayerController.value.duration.inMilliseconds;
    if (position == duration && !playEnd) {
      playEnd = true;
      logDebug("播放完毕");
      showCustomRateView(
          context, AppPreferenceKey.latest_play_complete_rate_date);
    }
    setState(() {
      progressValue = position / duration * 100;
      if (progressValue.isNaN || progressValue.isInfinite) {
        progressValue = 0.0;
      }
      labelProgress = DateUtil.formatDateMs(
        progressValue.toInt(),
        format: 'mm:ss',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
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
                          size: 140, color: AppTheme.nearlyWhite),
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
            Positioned(
              left: 16,
              top: (MediaQuery.of(context).padding.top) + 16,
              child: GestureDetector(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                  child: Container(
                    color: Colors.black26,
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.arrow_back,
                          size: 30, color: AppTheme.nearlyWhite),
                    ),
                  ),
                ),
                onTap: () {
                  if (mounted) videoPlayerController.dispose();
                  AppNavigator.popPage();
                },
              ),
            ),
            Positioned(
              right: 16,
              top: (MediaQuery.of(context).padding.top) + 16,
              child: GestureDetector(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                  child: Container(
                    color: Colors.black26,
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.save_alt,
                          size: 30, color: AppTheme.nearlyWhite),
                    ),
                  ),
                ),
                onTap: () {
                  showMessageDialog(
                    context,
                    const Text('defualt_alert_title').tr(),
                    const Text("save_video").tr(),
                    TextButton(
                      child: const Text('save').tr(),
                      onPressed: () async {
                        if (widget.localFilePath != null) {
                          await PhotoLibraryService()
                              .saveVideo(widget.localFilePath!);
                        }
                        AppNavigator.popPage();
                      },
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 155,
              left: 20,
              right: 0,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _buildAuthInfo(),
              ),
            ),
            Positioned(
              bottom: 135,
              left: 0,
              right: 0,
              height: 10,
              child: _buildVideoSlider(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 130,
              child: Container(
                color: Colors.black38,
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: _buildVideoInfo()),
              ),
            ),
            // SizedBox(
            //   height: MediaQuery.of(context).padding.bottom,
            // )
          ],
        ),
      ),
    );
  }

  Widget _buildAuthInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(30.0)),
          child: CachedNetworkImage(
            imageUrl: widget.metaData.avatar ?? "",
            errorWidget: (context, url, error) => const Icon(Icons.error),
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
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
      ],
    );
  }

  Widget _buildVideoSlider() {
    return Slider(
        activeColor: AppTheme.nearlyWhite,
        inactiveColor: AppTheme.dismissibleBackground,
        value: progressValue,
        label: labelProgress,
        divisions: 100,
        onChangeStart: _onChangeStart,
        onChangeEnd: _onChangeEnd,
        onChanged: _onChanged,
        min: 0,
        max: 100);
  }

  void _onChangeEnd(_) {
    int duration = videoPlayerController.value.duration.inMilliseconds;
    videoPlayerController.seekTo(
      Duration(milliseconds: (progressValue / 100 * duration).toInt()),
    );
    if (!videoPlayerController.value.isPlaying) videoPlayerController.play();
  }

  void _onChangeStart(_) {
    if (videoPlayerController.value.isPlaying) videoPlayerController.pause();
  }

  void _onChanged(double value) {
    int duration = videoPlayerController.value.duration.inMilliseconds;
    setState(() {
      progressValue = value;
      labelProgress = DateUtil.formatDateMs(
        (value / 100 * duration).toInt(),
        format: 'mm:ss',
      );
    });
  }

  Widget _buildVideoInfo() {
    return Column(
      children: [
        Expanded(
          child: Text(
            widget.metaData.title ?? "",
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
