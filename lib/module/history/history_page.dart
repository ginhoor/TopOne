import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/module/history/history_page_vm.dart';
import 'package:top_one/module/index/download_task_vm.dart';
import 'package:top_one/module/index/view/task_info_widget.dart';
import 'package:top_one/service/ad/ad_service.dart';
import 'package:top_one/service/ad/banner_ad_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/app_nav_bar.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> with TickerProviderStateMixin {
  final provider = ChangeNotifierProvider<HistoryPageVM>((ref) => HistoryPageVM());
  final downloadTaskProvider = ChangeNotifierProvider<DownloadTaskVM>((ref) => DownloadTaskVM());
  BannerADService? adService;

  @override
  void dispose() {
    adService?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    ref.read(downloadTaskProvider).loadTasks();
    ref.read(downloadTaskProvider).addOB();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppNavbar(Text(LocaleKeys.history.tr())),
      backgroundColor: AppTheme.background,
      body: WillPopScope(onWillPop: AppNavigator.handleOnWillPop, child: listView),
    );
  }

  Widget get listView {
    return Consumer(
      builder: (context, ref, child) {
        var adLoaded = ref.watch(provider).inlineadLoaded;
        var items = ref.watch(downloadTaskProvider).items;
        var count = adLoaded ? items.length + 1 : items.length;
        return ListView.builder(
          physics: ClampingScrollPhysics(), // 禁止滑动触顶和触底的动效
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + dPadding,
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
              padding: EdgeInsets.only(left: dPadding, right: dPadding, top: dPadding),
              child: buildTaskItem(context, item, ref, mounted, downloadTaskProvider),
            );
          },
        );
      },
    );
  }
}
