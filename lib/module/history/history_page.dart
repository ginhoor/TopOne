import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as path;
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/module/history/history_page_vm.dart';
import 'package:top_one/module/index/view/task_info_widget.dart';
import 'package:top_one/module/video/video_preview_page+route.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/ad/banner_ad_service.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/app_nav_bar.dart';
import 'package:top_one/view/toast.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with TickerProviderStateMixin {
  final provider = ChangeNotifierProvider<HistoryPageVM>((ref) => HistoryPageVM());

  BannerADService? adService;

  @override
  void dispose() {
    adService?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setupDownloadService();
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

  void setupDownloadService() {
    ref.read(provider).bindBackgroundIsolate();
    ref.read(provider).registerDownloaderCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppNavbar(Text(LocaleKeys.history.tr())),
      backgroundColor: AppTheme.background,
      body: _buildListView,
    );
  }

  Widget get _buildListView {
    return Consumer(
      builder: (context, ref, child) {
        var adLoaded = ref.watch(provider).inlineadLoaded;
        var items = ref.watch(provider).items;

        var count = adLoaded ? items.length + 1 : items.length;

        return ListView.builder(
          physics: ClampingScrollPhysics(), // 禁止滑动触顶和触底的动效
          padding: EdgeInsets.only(
            // top: MediaQuery.of(context).padding.top + (adService?.ad != null ? adService!.ad!.size.height : 0),
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          itemCount: count,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            if (adLoaded && index == 0) {
              return adService?.adWidget() ?? Container();
            }
            final itemIndex = adLoaded ? index - 1 : index;
            var item = items[itemIndex];
            return Padding(
              padding: adLoaded && itemIndex == 0
                  ? EdgeInsets.only(left: dPadding, right: dPadding)
                  : EdgeInsets.only(left: dPadding, right: dPadding, top: dPadding),
              child: buildTaskItem(context, item),
            );
          },
        );
      },
    );
  }

  Widget buildTaskItem(BuildContext context, TaskModel model) {
    return TaskInfoWidget(
      data: model,
      onTap: (model) async {
        AnalyticsService().logEvent(AnalyticsEvent.previewVideo);
        var vm = ref.read(provider);
        var exist = await vm.findCompletedTask(model.taskId);
        if (exist == null) {
          if (!mounted) return;
          showToast(context, Text(LocaleKeys.open_file_error.tr()));
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
      onDelete: (model) {
        var vm = ref.read(provider);
        vm.deleteDownloadTask(model.taskId);
      },
    );
  }
}
