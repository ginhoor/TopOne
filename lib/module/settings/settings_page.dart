import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/manager/store_manager.dart';
import 'package:top_one/manager/system_component_manager.dart';
import 'package:top_one/module/debug/debug_page+route.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/app_nav_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Widget> items = [];

  @override
  void initState() {
    setupItems();
    super.initState();
  }

  setupItems() {
    items.add(_buildTitleCell(LocaleKeys.rate.tr(), onTap: () => StoreManager.instance.openStorePage()));
    items.add(_buildTitleCell(LocaleKeys.contact_us.tr(),
        onTap: () => SystemComponentManager.instance.sendFeedbackEmail(context)));
    items.add(_buildTitleCell(LocaleKeys.privacy_policy.tr(),
        onTap: () => SystemComponentManager.instance.launchInBrowser(kPrivacyPolicyURL)));
    items.add(_buildTitleCell(LocaleKeys.terms_of_use.tr(),
        onTap: () => SystemComponentManager.instance.launchInBrowser(kTermsOfServiceURL)));

    items.add(versionCell);

    if (!kReleaseMode) {
      items.add(_buildTitleCell("DEBUG", onTap: () {
        var page = DebugPageRouteHandler().page();
        AppNavigator.pushRoute(page);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppNavbar(Text(LocaleKeys.about.tr())),
      body: WillPopScope(onWillPop: AppNavigator.handleOnWillPop, child: _content),
    );
  }

  Widget get _content {
    return Container(
      color: ColorName.background,
      child: ListView.builder(
        physics: ClampingScrollPhysics(), // 禁止滑动触顶和触底的动效
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        itemCount: items.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return items[index];
        },
      ),
    );
  }

  Widget get versionCell {
    String version = AppInfoModule.instance.appVersion;
    if (kDebugMode) version += '(${AppInfoModule.instance.sysInfo?.shortVer}) Debug';

    return Padding(
      padding: EdgeInsets.only(left: dPadding, right: dPadding),
      child: Column(
        children: [
          SizedBox(height: dPadding),
          Row(
            children: [
              Expanded(
                child: Text(LocaleKeys.version.tr(), style: TextStyle(fontSize: 15, color: ColorName.blackText)),
              ),
              SizedBox(width: dPadding),
              Text(version, style: TextStyle(fontSize: 15, color: ColorName.deactivatedText)),
            ],
          ),
          SizedBox(height: dPadding),
        ],
      ),
    );
  }

  Widget _buildTitleCell(String title, {String? value, void Function()? onTap}) {
    return SizedBox(
      height: 50,
      child: MaterialButton(
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(
              child:
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: ColorName.blackText)),
            ),
            value != null
                ? Expanded(
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: ColorName.deactivatedText),
                    ),
                  )
                : Container(),
            Icon(Icons.keyboard_arrow_right_rounded)
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: dBorderRadius),
      ),
    );
  }
}
