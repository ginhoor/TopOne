import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gh_tool_package/log/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:top_one/api/req_ttd_api.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/module/history/history_screen.dart';
import 'package:top_one/module/index/index_screen_vm.dart';
import 'package:top_one/module/index/view/index_task_info_widget.dart';
import 'package:top_one/module/settings/settings_screen.dart';
import 'package:top_one/module/video/video_preview_screen.dart';
import 'package:top_one/service/ad/Inline_ad_service.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/view/app_top_bar.dart';
import 'package:top_one/view/toast.dart';

import 'view/clipboard_widget.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen>
    with TickerProviderStateMixin {
  var vm = IndexScreenVM();
  late Animation<double> topBarAnimation;

  // 进入页面后的动效时长
  late AnimationController animationController;
  final scrollController = ScrollController();

  InlineADService? adService;

  @override
  void dispose() {
    adService?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    scrollController.addListener(_handleTopBarWhenScroll);
    vm.bindBackgroundIsolate();
    vm.registerDownloaderCallback();
    animationController.forward();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await setupAd();
    super.didChangeDependencies();
  }

  static const _insets = 16.0;
  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);
  setupAd() async {
    // Get an inline adaptive size for the current orientation.
    int width = _adWidth.truncate();
    AdSize size = AdSize.getInlineAdaptiveBannerAdSize(
        width, (width / 328.0 * 310.0).truncate());

    adService = InlineADService(ADService.TESTBannerUnitId,
        // kDebugMode ? ADService().TESTBannerUnitId : ADService().bannderUnitId1,
        size: size, onAdLoaded: (p0) {
      vm.setInlineadLoaded();
    });
    adService?.load();
  }

  Future<bool> handleDownloadAction(String text) async {
    if (text.isEmpty) return false;
    AnalyticsService().logEvent(AnalyticsEvent.tapDownload);
    var url = text;
    if (!TTResult.verifyURL(url)) {
      if (mounted) showToast(context, const Text("url_invaild_error").tr());
      return false;
    }
    await EasyLoading.show(status: "chacking".tr());
    try {
      var result = await HttpApi().getTTResult(url);
      var success = await vm.createDownloadTask(result);
      await EasyLoading.dismiss();
      if (success) {
        ADService().indexINTAdService.show((p0) => null);
        return true;
      } else {
        if (mounted) {
          showToast(context, const Text("create_task_failed_error").tr());
        }
        return false;
      }
    } catch (e) {
      logDebug("handleDownloadAction", e);
      await EasyLoading.dismiss();
      if (mounted) {
        showToast(context, const Text("create_task_failed_error").tr());
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: <Widget>[
            _buildContent(),
            _buildAppTopBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTopBar() {
    return Selector(
      builder: (context, topBarOpacity, _) {
        return AppTopBar(
          animationController,
          topBarAnimation,
          topBarOpacity,
          tapSettings: () {
            AppNavigator.pushPage(const SettingsScreen());
          },
          tapDownloadList: () async {
            ADService().historyINTAdService.show((p0) async {
              AppNavigator.pushPage(const HistoryScreen());
            });
          },
        );
      },
      selector: (BuildContext context, IndexScreenVM vm) {
        return vm.topBarOpacity;
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            15,
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      child: IntrinsicHeight(
        child: Column(
          children: [
            ClipboardWidget(
              animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: const Interval((1 / 9) * 1, 1.0,
                      curve: Curves.fastOutSlowIn),
                ),
              ),
              animationController: animationController,
              handleDownload: handleDownloadAction,
            ),
            Selector(
              builder: (BuildContext context, String version, _) {
                if (vm.currentTask == null) return Container();
                return buildTaskItem(context, vm.currentTask!);
              },
              selector: (BuildContext context, IndexScreenVM vm) {
                return vm.itemsVersion;
              },
            ),
            Selector(
              builder: (BuildContext context, bool inlineadLoaded, _) {
                return adService?.adWidget() ?? Container();
              },
              selector: (BuildContext context, IndexScreenVM vm) {
                return vm.inlineadLoaded;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskItem(BuildContext context, TaskModel model) {
    return IndexTaskInfoWidget(
      data: model,
      onTap: (model) async {
        AnalyticsService().logEvent(AnalyticsEvent.previewVideo);
        var exist = await vm.findCompletedTask(model.taskId);
        if (exist == null) {
          if (!mounted) return;
          showToast(context, const Text('open_file_error').tr());
          return;
        }
        var metaData = model.metaData;
        var filePath = path.join(exist.savedDir, exist.filename);
        AppNavigator.pushPage(VideoPreviewScreen(
          metaData: metaData,
          localFilePath: filePath,
        ));
      },
      onActionTap: (model) async {
        if (model.status == DownloadTaskStatus.undefined) {
        } else if (model.status == DownloadTaskStatus.running) {
          await vm.pauseDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.paused) {
          await vm.resumeDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.complete ||
            model.status == DownloadTaskStatus.canceled) {
          await vm.deleteDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.failed) {
          await vm.retryDownloadTask(model.taskId);
        }
      },
      onCancel: (model) {
        vm.deleteDownloadTask(model.taskId);
      },
    );
  }

  void _handleTopBarWhenScroll() {
    if (scrollController.offset >= 24) {
      if (vm.topBarOpacity != 1.0) vm.updateTopBarOpacity(1.0);
    } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
      var val = scrollController.offset / 24;
      if (vm.topBarOpacity != val) vm.updateTopBarOpacity(val);
    } else if (scrollController.offset <= 0) {
      if (vm.topBarOpacity != 0.0) vm.updateTopBarOpacity(0.0);
    }
  }
}
