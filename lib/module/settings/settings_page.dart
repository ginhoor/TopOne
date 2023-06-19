import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gh_tool_package/system/web.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/tool/store_kit.dart';
import 'package:top_one/view/app_nav_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Widget> staticCells = [];

  @override
  void initState() {
    setupStaticCells();
    super.initState();
  }

  setupStaticCells() {
    staticCells.add(_buildTitleCell(
      "rate",
      onTap: () {
        showRateDialog(context);
      },
    ));
    staticCells.add(_buildTitleCell(
      "privacy_policy",
      onTap: () => launchInBrowser(kPrivacyPolicyURL),
    ));
    staticCells.add(_buildTitleCell(
      "terms_of_use",
      onTap: () => launchInBrowser(kTermsOfServiceURL),
    ));
    staticCells.add(_buildAppCell());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppNavbar(const Text("about").tr()),
      body: Container(
        color: const Color(0x00f2f2f7),
        child: ListView.builder(
          padding: EdgeInsets.only(
            bottom: 62 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: staticCells.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return staticCells[index];
          },
        ),
      ),
    );
  }

  Widget _buildAppCell() {
    String version = '${AppInfoModule.instance.appVersion}(${AppInfoModule.instance.sysInfo?.shortVer})';
    if (kDebugMode) version += 'Debug';

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: const Text(
                  'version',
                  style: TextStyle(fontSize: 17, color: Color(0xFF303337)),
                ).tr(),
              ),
              const SizedBox(width: 20),
              Text(
                version,
                style: const TextStyle(fontSize: 16, color: Color(0xFF7C96A7)),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTitleCell(String title, {String? value, void Function()? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF303337),
                    ),
                  ).tr(),
                ),
                value != null
                    ? Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7C96A7),
                          ),
                        ),
                      )
                    : Container(),
                const Icon(Icons.keyboard_arrow_right_rounded)
              ],
            ),
          ),
        ));
  }

  // Widget _buildFeatures(BuildContext context) {
  //   return ListView.separated(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: aboutList.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       return _buildFeatureTile(context, index);
  //     },
  //     separatorBuilder: (BuildContext context, int index) {
  //       return UIConstant.kDivider;
  //     },
  //   );
  // }

  // Widget _buildFeatureTile(BuildContext context, int idx) {
  //   bool newVersionUpdate = aboutList[idx].name == '最新版本下载';
  //   return Material(
  //     color: Colors.white,
  //     child: ListTile(
  //       title: Row(
  //         children: [
  //           // NetworkImageCacheManager.networkImage(
  //           //   imageUrl: aboutList[idx].icon,
  //           //   width: 20,
  //           //   height: 20,
  //           // ),
  //           // SizedBox(width: UIConstant.kHorizontalPadding),
  //           Text(
  //             aboutList[idx].name,
  //             style: Theme.of(context).textTheme.headline5,
  //           ),
  //           const SizedBox(width: 10),
  //           Visibility(
  //               visible:
  //                   newVersionUpdate && UpdateHelper.isUpdateLocal(context),
  //               child: Container(
  //                 width: 10,
  //                 height: 10,
  //                 constraints:
  //                     const BoxConstraints(minWidth: 10, minHeight: 10),
  //                 alignment: Alignment.center,
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10.0),
  //                     color: Colors.red),
  //               )),
  //           Visibility(
  //               visible: newVersionUpdate,
  //               child: Expanded(
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(right: 10),
  //                   child: Text(
  //                     AppGlobalConfigManager().appGlobalConfig?.flutterUpdate !=
  //                             null
  //                         ? "V ${AppGlobalConfigManager().appGlobalConfig?.flutterUpdate?.versionName ?? ""}"
  //                         : '',
  //                     textAlign: TextAlign.end,
  //                     style: Theme.of(context).textTheme.headline5.copyWith(
  //                         color: DefaultLightThemeColors.bottomTabbarColor),
  //                   ),
  //                 ),
  //               ))
  //         ],
  //       ),
  //       onTap: () {
  //         if (!newVersionUpdate) {
  //           WebPage.openWebView(
  //               title: aboutList[idx].name, url: aboutList[idx].url);
  //           return;
  //         }

  //         if (UpdateHelper.isUpdateLocal(context)) {
  //           if (Platform.isAndroid) {
  //             UpdateHelper.showUpdateAppDialog(true);
  //           } else {
  //             String url = aboutList[idx].url;
  //             if (url == null) {
  //               return;
  //             }
  //             logDebug('YochatOpenUrl: $url');
  //             YochatOpenUrl.appOpenURL(url);
  //           }
  //         } else {
  //           Utils.showToast('已经是最新版本');
  //         }
  //       },
  //     ),
  //   );
  // }
}
