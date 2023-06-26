import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as path;
import 'package:top_one/api/ttd_request.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/module/history/history_page+route.dart';
import 'package:top_one/module/index/index_page_vm.dart';
import 'package:top_one/module/index/view/task_info_widget.dart';
import 'package:top_one/module/settings/settings_page+route.dart';
import 'package:top_one/module/video/video_preview_page+route.dart';
import 'package:top_one/service/ad/Inline_ad_service.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/app_top_bar.dart';
import 'package:top_one/view/toast.dart';

import 'view/clipboard_widget.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> with TickerProviderStateMixin {
  final provider = ChangeNotifierProvider<IndexPageVM>((ref) => IndexPageVM());

  InlineADService? adService;

  @override
  void dispose() {
    adService?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var vm = ref.read(provider);
    vm.bindBackgroundIsolate();
    vm.registerDownloaderCallback();
  }

  @override
  void didChangeDependencies() async {
    await setupAd();
    super.didChangeDependencies();
  }

  double get _adWidth => MediaQuery.of(context).size.width - (2 * dPadding);
  double get _adHeight {
    return MediaQuery.of(context).size.height - 88 - 146 - 122;
  }

  Future<void> setupAd() async {
    AdSize size = AdSize.getInlineAdaptiveBannerAdSize(_adWidth.truncate(), _adHeight.truncate());
    adService = InlineADService(kDebugMode ? ADService.TESTBannerUnitId : ADService.bannderUnitId1, size: size,
        onAdLoaded: (p0) {
      ref.read(provider).setInlineadLoaded();
    });
    adService?.load();
  }

  Future<bool> handleDownloadAction(String text) async {
    if (text.isEmpty) return false;
    AnalyticsService().logEvent(AnalyticsEvent.tapDownload);
    var url = text;
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    if (!TTResult.verifyURL(url)) {
      if (mounted) ToastManager.instance.showTextToast(context, LocaleKeys.url_invaild_error.tr());
      return false;
    }
    await EasyLoading.show(status: LocaleKeys.chacking.tr(), dismissOnTap: false);
    try {
      var result = await TDDResultRequest().requestResult(url);
      if (result == null) {
        await EasyLoading.dismiss();
        if (mounted) ToastManager.instance.showTextToast(context, LocaleKeys.create_task_failed_error.tr());
        return false;
      }
      var success = await ref.read(provider).createDownloadTask(result);
      await EasyLoading.dismiss();
      if (success) {
        ADService().indexINTAdService.show((p0) => null);
        return true;
      } else {
        if (mounted) ToastManager.instance.showTextToast(context, LocaleKeys.create_task_failed_error.tr());
        return false;
      }
    } catch (e) {
      logWarn("handleDownloadAction", e);
      await EasyLoading.dismiss();
      if (mounted) ToastManager.instance.showTextToast(context, LocaleKeys.create_task_failed_error.tr());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: _body),
    );
  }

  Widget get _body {
    return Column(children: <Widget>[
      _topBar,
      _content,
    ]);
  }

  Widget get _topBar {
    return AppTopBar(
      hasNewHistory: AppPreference.instance.getInt(AppPreferenceKey.hasNewHistoryDate.value) != null,
      tapSettings: () {
        FocusScope.of(context).unfocus();
        AppNavigator.pushRoute(SettingsPageRouteHandler.instance.page());
      },
      tapDownloadList: () async {
        FocusScope.of(context).unfocus();
        await EasyLoading.show(dismissOnTap: false);
        ADService().historyINTAdService.show((p0) async {
          await EasyLoading.dismiss();
          AppNavigator.pushRoute(HistoryPageRouteHandler.instance.page());
          AppPreference.instance.remove(AppPreferenceKey.hasNewHistoryDate.value);
        });
      },
    );
  }

  Widget get _content {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(), // 禁止滑动触顶和触底的动效
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: dPadding_2, left: dPadding, right: dPadding, bottom: dPadding),
            child: ClipboardWidget(handleDownload: handleDownloadAction),
          ),
          Consumer(
            builder: (context, ref, child) {
              var task = ref.watch(provider).currentTask;
              if (task == null) return Container();
              return Padding(
                padding: EdgeInsets.only(left: dPadding, right: dPadding, bottom: dPadding),
                child: buildTaskItem(context, task),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              var loaded = ref.watch(provider).inlineadLoaded;
              var adWidget = adService?.adWidget();
              logDebug("[ad] index ad loaded: $loaded, widget: $adWidget");
              return adWidget ?? Container();
            },
          ),
        ],
      ),
    );
  }

  Widget buildTaskItem(BuildContext context, TaskModel model) {
    return TaskInfoWidget(
      data: model,
      onTap: (_) async {
        AnalyticsService().logEvent(AnalyticsEvent.previewVideo);
        var task = ref.read(provider).currentTask;
        if (task == null) return;
        var exist = await ref.read(provider).findCompletedTask(task.taskId);
        if (exist == null) {
          if (mounted) ToastManager.instance.showTextToast(context, LocaleKeys.open_file_error.tr());
          return;
        }
        var metaData = task.metaData;
        var filePath = path.join(exist.savedDir, exist.filename);
        AppNavigator.pushRoute(VideoPreviewPageRouteHandler.instance.page(metaData, filePath));
      },
      onActionTap: (_) async {
        var vm = ref.read(provider);
        var task = vm.currentTask;
        if (task == null) return;
        if (task.status == DownloadTaskStatus.undefined) {
        } else if (task.status == DownloadTaskStatus.running) {
          await vm.pauseDownloadTask(task.taskId);
        } else if (task.status == DownloadTaskStatus.paused) {
          await vm.resumeDownloadTask(task.taskId);
        } else if (task.status == DownloadTaskStatus.complete || task.status == DownloadTaskStatus.canceled) {
          await vm.deleteDownloadTask(task.taskId);
        } else if (task.status == DownloadTaskStatus.failed) {
          await vm.retryDownloadTask(task.taskId);
        }
      },
      onDelete: (_) async {
        var task = ref.read(provider).currentTask;
        if (task == null) return;
        await ref.read(provider).deleteDownloadTask(task.taskId);
      },
    );
  }
}
