import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gh_tool_package/system/web.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/generated/locale_keys.g.dart';
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
    staticCells.add(_buildTitleCell(LocaleKeys.rate.tr(), onTap: () => showRateView()));
    staticCells.add(_buildTitleCell(
      LocaleKeys.privacy_policy.tr(),
      onTap: () => launchInBrowser(kPrivacyPolicyURL),
    ));
    staticCells.add(_buildTitleCell(
      LocaleKeys.terms_of_use.tr(),
      onTap: () => launchInBrowser(kTermsOfServiceURL),
    ));
    staticCells.add(_buildAppCell());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppNavbar(Text(LocaleKeys.about.tr())),
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
                child: Text(
                  LocaleKeys.version.tr(),
                  style: TextStyle(fontSize: 17, color: Color(0xFF303337)),
                ),
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
}