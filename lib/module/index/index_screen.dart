import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/module/index/index_screen_vm.dart';
import 'package:top_one/module/index/view/index_task_info_widget.dart';
import 'package:top_one/module/video/video_preview_screen.dart';
import 'package:top_one/service/ad/app_lifecycle_reactor.dart';
import 'package:top_one/service/ad/app_open_ad_manager.dart';
import 'package:top_one/service/ad/native_ad_service.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/tool/logger.dart';
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
  List<Widget> topCells = [];
  List<Widget> bottomCells = [];

  NativeAd? ad;
  // 进入页面后的动效时长
  late AnimationController animationController;
  final scrollController = ScrollController();

  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void dispose() {
    ad?.dispose();
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
    setupDownloader();
    setupAd();
    animationController.forward();

    // vm.loadTasks();
    super.initState();
    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
  }

  setupDownloader() {
    vm.bindBackgroundIsolate();
    vm.registerDownloaderCallback();
  }

  setupAd() {
    NativeAd(
      adUnitId: NativeADService.adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          logDebug('$NativeAd loaded.');
          setState(() {
            this.ad = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          logDebug('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => logDebug('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => logDebug('$NativeAd onAdClosed.'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.purple,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.cyan,
          backgroundColor: Colors.red,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.red,
          backgroundColor: Colors.cyan,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.green,
          backgroundColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.brown,
          backgroundColor: Colors.amber,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: vm,
      child: Scaffold(
        backgroundColor: FitnessAppTheme.background,
        body: Stack(
          children: <Widget>[
            _buildContent(),
            SizedBox(height: 200, child: _buildAppTopBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTopBar() {
    return Selector(
      builder: (context, topBarOpacity, _) {
        return AppTopBar(animationController, topBarAnimation, topBarOpacity);
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
            24,
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
            if (ad != null)
              SizedBox(height: 600, child: AdWidget(ad: ad!))
            else
              Container()
          ],
        ),
      ),
    );
  }

  // Widget _buildContent() {
  //   return LayoutBuilder(
  //       builder: (BuildContext context, BoxConstraints constraints) {
  //     return SingleChildScrollView(
  //       controller: scrollController,
  //       padding: EdgeInsets.only(
  //         top: AppBar().preferredSize.height +
  //             MediaQuery.of(context).padding.top +
  //             24,
  //         bottom: 62 + MediaQuery.of(context).padding.bottom,
  //       ),
  //       child: ConstrainedBox(
  //         constraints: constraints.copyWith(
  //           minHeight: constraints.maxHeight,
  //           maxHeight: double.infinity,
  //         ),
  //         child: IntrinsicHeight(
  //           child: Column(
  //             children: [
  //               ClipboardWidget(
  //                 animation: Tween<double>(begin: 0.0, end: 1.0).animate(
  //                   CurvedAnimation(
  //                     parent: animationController,
  //                     curve: const Interval((1 / 9) * 1, 1.0,
  //                         curve: Curves.fastOutSlowIn),
  //                   ),
  //                 ),
  //                 animationController: animationController,
  //               ),
  //               Selector(
  //                 builder: (BuildContext context, String version, _) {
  //                   if (vm.currentTask == null) return Container();

  //                   return buildTaskItem(context, vm.currentTask!);
  //                 },
  //                 selector: (BuildContext context, IndexScreenVM vm) {
  //                   return vm.itemsVersion;
  //                 },
  //               ),
  //               Container(
  //                 color: Colors.amber,
  //                 child: SizedBox(
  //                   height: 100,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  // }

  Widget _buildListView() {
    return Selector(
      builder: (BuildContext context, String version, _) {
        return Container();
      },
      selector: (BuildContext context, IndexScreenVM vm) {
        return vm.itemsVersion;
      },
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
