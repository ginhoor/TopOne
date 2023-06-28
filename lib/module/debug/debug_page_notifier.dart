import 'package:flutter/material.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/view/dialog.dart';

enum DEBUGKeychainStorageKey {
  mockVIP("mockVIP"),
  hookHTTPEnable("hookHTTPEnable"),
  proxyIP("proxyIP"),
  proxyPort("proxyPort");

  const DEBUGKeychainStorageKey(this.key);
  final String key;
}

class DebugItem {
  String title;
  void Function(BuildContext context)? action;
  DebugItem({required this.title, required this.action});
}

class DebugPageNotifier extends ChangeNotifier {
  List<DebugItem> items = [];

  load() {
    items = [
      _resetRecord,
      _hookHTTP,
    ];
  }

  DebugItem get _hookHTTP {
    return DebugItem(
      title: "HTTP抓包配置",
      action: (BuildContext context) async {
        var ipTextCtrl = TextEditingController();
        var portTextCtrl = TextEditingController();
        var enable = AppPreference.instance.getBool(DEBUGKeychainStorageKey.hookHTTPEnable.key);
        var currentIP = AppPreference.instance.getString(DEBUGKeychainStorageKey.proxyIP.key);
        var currentPort = AppPreference.instance.getString(DEBUGKeychainStorageKey.proxyPort.key);
        ipTextCtrl.text = currentIP ?? "";
        portTextCtrl.text = currentPort ?? "";

        DialogManager.instance.showWidgetDialog(
          context,
          title: Text("当前抓包启用状态：$enable",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)),
          message: Column(
            children: [
              TextField(
                controller: ipTextCtrl,
                decoration: InputDecoration(hintText: '输入 ip, 如“192.168.2.1”'),
              ),
              TextField(
                controller: portTextCtrl,
                decoration: InputDecoration(hintText: '输入 port, 如“8888”'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("开启抓包(需要重启App)", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                AppPreference.instance.setBool(DEBUGKeychainStorageKey.hookHTTPEnable.key, true);
                AppPreference.instance.setString(DEBUGKeychainStorageKey.proxyIP.key, ipTextCtrl.text);
                AppPreference.instance.setString(DEBUGKeychainStorageKey.proxyPort.key, portTextCtrl.text);
                AppNavigator.popPage();
              },
            ),
            TextButton(
              child: Text("关闭抓包", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                AppPreference.instance.setBool(DEBUGKeychainStorageKey.hookHTTPEnable.key, false);

                AppNavigator.popPage();
              },
            ),
          ],
        );
      },
    );
  }

  DebugItem get _resetRecord {
    return DebugItem(
      title: "重置记录",
      action: (BuildContext context) async {
        DialogManager.instance.showWidgetDialog(
          context,
          title: Text("重置记录", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black)),
          actions: [
            TextButton(
              child: Text("重置首次隐私确认", style: TextStyle(color: Colors.black)),
              onPressed: () async {
                await AppPreference.instance.remove(AppPreferenceKey.latestAgreePrivacyDate.value);
                AppNavigator.popPage();
              },
            ),
          ],
        );
      },
    );
  }
}
