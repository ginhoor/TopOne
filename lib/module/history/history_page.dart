import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as path;
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/module/history/history_page_vm.dart';
import 'package:top_one/module/index/view/history_task_info_widget.dart';
import 'package:top_one/module/video/video_preview_page+route.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/ad/banner_ad_service.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/view/app_nav_bar.dart';
import 'package:top_one/view/toast.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with TickerProviderStateMixin {
  final provider = ChangeNotifierProvider<HistoryPageVM>((ref) => HistoryPageVM());
  late Animation<double> topBarAnimation;
  // List<Widget> staticCells = [];
  // // 进入页面后的动效时长
  // late AnimationController animationController;
  final scrollController = ScrollController();
  BannerADService? adService;

  @override
  void dispose() {
    adService?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setupDownloader();
    ref.read(provider).loadTasks();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await setupAd();
    super.didChangeDependencies();
  }

  setupAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(MediaQuery.of(context).size.width.truncate());
    if (size == null) return;
    adService = BannerADService(kDebugMode ? ADService.TESTBannerUnitId : ADService.bannderUnitId2, size: size,
        onAdLoaded: (p0) {
      ref.read(provider).setInlineadLoaded();
    });
    adService?.load();
  }

  setupDownloader() {
    ref.read(provider).bindBackgroundIsolate();
    ref.read(provider).registerDownloaderCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppNavbar(const Text("download").tr()),
      backgroundColor: AppTheme.background,
      body: Stack(
        children: <Widget>[
          _buildListView(),
          Consumer(
            builder: (context, ref, child) {
              var _ = ref.watch(provider).inlineadLoaded;
              return adService?.adWidget() ?? Container();
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom)
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Consumer(
      builder: (context, ref, child) {
        var items = ref.watch(provider).items;
        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + (adService?.ad != null ? adService!.ad!.size.height : 0),
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          itemCount: items.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            var item = items[index];
            return buildTaskItem(context, item);
          },
        );
      },
    );
  }

  Widget buildTaskItem(BuildContext context, TaskModel model) {
    return HistoryTaskInfoWidget(
      data: model,
      onTap: (model) async {
        AnalyticsService().logEvent(AnalyticsEvent.previewVideo);
        var vm = ref.read(provider);
        var exist = await vm.findCompletedTask(model.taskId);
        if (exist == null) {
          if (!mounted) return;
          showToast(context, const Text('open_file_error').tr());
          return;
        }
        var metaData = model.metaData;
        var filePath = path.join(exist.savedDir, exist.filename);
        AppNavigator.pushRoute(VideoPreviewPageRouteHandler.instance.page(metaData, filePath));
      },
      onActionTap: (model) async {
        var vm = ref.read(provider);
        if (model.status == DownloadTaskStatus.undefined) {
        } else if (model.status == DownloadTaskStatus.running) {
          await vm.pauseDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.paused) {
          await vm.resumeDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.complete || model.status == DownloadTaskStatus.canceled) {
          await vm.deleteDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.failed) {
          await vm.retryDownloadTask(model.taskId);
        }
      },
      onCancel: (model) {
        var vm = ref.read(provider);
        vm.deleteDownloadTask(model.taskId);
      },
    );
  }
}
