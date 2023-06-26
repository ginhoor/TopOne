import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/manager/photo_library_manager.dart';
import 'package:top_one/manager/store_manager.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/dialog.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewPage extends StatefulWidget {
  final TTResult metaData;
  final String? localFilePath;
  const VideoPreviewPage({super.key, required this.metaData, this.localFilePath});
  @override
  State<VideoPreviewPage> createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> with WidgetsBindingObserver {
  late VideoPlayerController _videoCtrl;
  double progressValue = 0; //进度

  bool playEnd = false;
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoCtrl.removeListener(listen);
    _videoCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    super.dispose();
    ADService().videoPlayINTAdService.show((p0) => null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        _videoCtrl.pause();
        break;
      case AppLifecycleState.resumed:
        _videoCtrl.play();
        break;
      case AppLifecycleState.paused:
        _videoCtrl.pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    var localFilePath = widget.localFilePath;

    if (localFilePath != null) {
      var file = File(localFilePath);
      _videoCtrl = VideoPlayerController.file(file);
    } else if (widget.metaData.video != null) {
      _videoCtrl = VideoPlayerController.network(widget.metaData.video!);
    } else {
      _videoCtrl = VideoPlayerController.asset("");
    }
    _videoCtrl.addListener(listen);
    _videoCtrl.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _videoCtrl.play();
      });
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void handleSaveAction() {
    DialogManager.instance.showMessageDialog(
      context,
      title: Text(LocaleKeys.save_video.tr()),
      actions: [
        TextButton(
          child: Text(LocaleKeys.save.tr()),
          onPressed: () async {
            await EasyLoading.show(dismissOnTap: false);
            if (widget.localFilePath != null) {
              await PhotoLibraryManager.instance.saveVideo(widget.localFilePath!);
            }
            await EasyLoading.dismiss();
            AppNavigator.popPage();
            StoreManager.instance.showInAppReview();
          },
        ),
      ],
    );
  }

  void handlePlayAction() {
    setState(() {
      _videoCtrl.value.isPlaying ? _videoCtrl.pause() : _videoCtrl.play();
    });
  }

  void listen() {
    int position = _videoCtrl.value.position.inMilliseconds;
    int duration = _videoCtrl.value.duration.inMilliseconds;
    setState(() {
      if (duration == 0) {
        progressValue = 0;
      } else {
        progressValue = position / duration * 100;
        if (progressValue.isNaN || progressValue.isInfinite) {
          progressValue = 0.0;
        }
      }
    });
  }

  String get labelProgress {
    int duration = _videoCtrl.value.duration.inMilliseconds;
    if (duration == 0) return "00:00";
    int progress = (progressValue / 100 * duration).toInt();
    return ms_to_mm_ss(progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: WillPopScope(onWillPop: AppNavigator.handleOnWillPop, child: _content),
    );
  }

  Widget get _content {
    return Stack(
      children: <Widget>[
        Align(alignment: Alignment.center, child: _player),
        Align(alignment: Alignment.center, child: _playAction),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min, // 设置 Column 的高度为子项内容的高度
            children: [
              _authInfo,
              SizedBox(height: dPadding_2),
              _timeSlider,
              SizedBox(height: dPadding_2),
              _videoInfo,
            ],
          ),
        ),
        Positioned(left: dPadding, top: (MediaQuery.of(context).padding.top), child: _back),
        if (widget.localFilePath != null)
          Positioned(right: dPadding, top: (MediaQuery.of(context).padding.top), child: _save),
      ],
    );
  }

  Widget get _player {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AspectRatio(
        aspectRatio: _videoCtrl.value.aspectRatio,
        child: _videoCtrl.value.isInitialized
            ? VideoPlayer(_videoCtrl)
            : CachedNetworkImage(imageUrl: widget.metaData.img ?? ""),
      ),
    );
  }

  Widget get _playAction {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: _videoCtrl.value.isPlaying
            ? null
            : Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(60.0)),
                      child: Container(
                        color: Colors.black45,
                        width: 120,
                        height: 120,
                        child: Icon(Icons.play_arrow, size: 120, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      onTap: () => handlePlayAction(),
    );
  }

  Widget get _back {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
        child: Container(
          color: Colors.black45,
          width: 50,
          height: 50,
          child: Icon(Icons.arrow_back, size: 30, color: Colors.white),
        ),
      ),
      onTap: () async {
        await _videoCtrl.pause();
        AppNavigator.popPage();
      },
    );
  }

  Widget get _save {
    return GestureDetector(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
          child: Container(
            color: Colors.black45,
            width: 50,
            height: 50,
            child: Icon(Icons.save_alt, size: 30, color: Colors.white),
          ),
        ),
        onTap: () => handleSaveAction());
  }

  Widget get _videoInfo {
    return Container(
      width: double.infinity,
      color: Colors.black38,
      child: Padding(
        padding: EdgeInsets.all(dPadding),
        child: Text(
          widget.metaData.title ?? "",
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget get _authInfo {
    return Padding(
      padding: EdgeInsets.only(left: dPadding, right: dPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(30.0)),
            child: CachedNetworkImage(
              imageUrl: widget.metaData.avatar ?? "",
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.metaData.name ?? "",
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget get _timeSlider {
    return SizedBox(
      height: 20,
      child: Slider(
          activeColor: Colors.white,
          inactiveColor: ColorName.dismissibleBackground,
          value: progressValue,
          label: labelProgress,
          divisions: 100,
          onChangeStart: _onChangeStart,
          onChangeEnd: _onChangeEnd,
          onChanged: _onChanged,
          min: 0,
          max: 100),
    );
  }

  void _onChangeEnd(_) async {
    int duration = _videoCtrl.value.duration.inMilliseconds;
    int newPosition = (progressValue / 100 * duration).toInt();
    await _videoCtrl.seekTo(
      Duration(milliseconds: newPosition),
    );

    if (progressValue != 100 && !_videoCtrl.value.isPlaying) {
      await _videoCtrl.play();
    }
  }

  void _onChangeStart(_) async {
    if (_videoCtrl.value.isPlaying) await _videoCtrl.pause();
  }

  void _onChanged(double value) {
    setState(() {
      progressValue = value;
    });
  }
}
