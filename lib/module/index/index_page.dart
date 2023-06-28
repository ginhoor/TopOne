import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/api/ttd_request.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/module/history/history_page+route.dart';
import 'package:top_one/module/index/download_task_vm.dart';
import 'package:top_one/module/index/index_page_vm.dart';
import 'package:top_one/module/index/view/task_info_widget.dart';
import 'package:top_one/module/settings/settings_page+route.dart';
import 'package:top_one/service/ad/Inline_ad_service.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/app_top_bar.dart';
import 'package:top_one/view/hud_easy_loading.dart';
import 'package:top_one/view/toast.dart';

import 'view/clipboard_widget.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> with TickerProviderStateMixin {
  final downloadTaskProvider = ChangeNotifierProvider<DownloadTaskVM>((ref) => DownloadTaskVM());
  final provider = ChangeNotifierProvider<IndexPageVM>((ref) => IndexPageVM());
  InlineADService? adService;

  @override
  void dispose() {
    adService?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    ref.read(downloadTaskProvider).addOB();
    super.initState();
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
    await HUDEasyLoading.showLoading(status: LocaleKeys.chacking.tr());
    try {
      var result = await TDDResultRequest().requestResult(url);
      if (result == null) {
        await HUDEasyLoading.dismiss();
        if (mounted) ToastManager.instance.showTextToast(context, LocaleKeys.create_task_failed_error.tr());
        return false;
      }
      var success = await ref.read(downloadTaskProvider).createDownloadTask(result);
      await HUDEasyLoading.dismiss();
      if (success) {
        ADService().indexINTAdService.show((p0) => null);
        return true;
      } else {
        if (mounted) ToastManager.instance.showTextToast(context, LocaleKeys.create_task_failed_error.tr());
        return false;
      }
    } catch (e) {
      logWarn("handleDownloadAction", e);
      await HUDEasyLoading.dismiss();
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
        await HUDEasyLoading.showLoading();
        ADService().historyINTAdService.show((p0) async {
          await HUDEasyLoading.dismiss();
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
            child: ClipboardWidget(downloadByURL: handleDownloadAction),
          ),
          Consumer(
            builder: (context, ref, child) {
              var tasks = ref.watch(downloadTaskProvider).items;
              if (tasks.isEmpty) return Container();
              var task = tasks.first;
              // logDebug("[item] task.id: ${task.taskId}, task.status ${task.status}, task progress ${task.progress}");
              return Padding(
                padding: EdgeInsets.only(left: dPadding, right: dPadding, bottom: dPadding),
                child: buildTaskItem(context, task, ref, mounted, downloadTaskProvider),
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
}
