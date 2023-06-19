import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_tool_kit/interface/app_module_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';

String appName = "Top One";

const kPrivacyPolicyURL = "https://gfrtopone.github.io/privacy-policy.html";
const kTermsOfServiceURL = "https://gfrtopone.github.io/terms-of-service.html";

class SysInfo {
  late String os;
  String brand;
  String device;
  String systemVersion;
  String packageName;
  String shortVer;

  SysInfo.iOS({
    required this.systemVersion,
    required this.device,
    required this.brand,
    required this.packageName,
    required this.shortVer,
  }) {
    os = 'iOS';
  }

  SysInfo.android({
    required this.systemVersion,
    required this.device,
    required this.brand,
    required this.packageName,
    required this.shortVer,
  }) {
    os = 'Android';
  }
}

class AppInfoModule implements AppModuleInterface {
  static final AppInfoModule instance = AppInfoModule._instance();
  factory AppInfoModule() => instance;
  AppInfoModule._instance();

  String _appVersion = "0.0.0";
  String get appVersion => _appVersion;
  SysInfo? sysInfo;

  @override
  int modulePriority = 5000;

  @override
  Future<void> loadModule() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;

    Map<String, dynamic> sysInfo = {};
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      sysInfo['os'] = 'Android';
      sysInfo['brand'] = info.brand;
      sysInfo['device'] = '${info.brand} ${info.model}';
      sysInfo['verRelease'] = info.version.release;
      sysInfo['androidSDK'] = info.version.sdkInt;
      AppInfoModule.instance.sysInfo = SysInfo.android(
        systemVersion: '${info.version.release}-${info.version.sdkInt}',
        device: '${info.brand} ${info.model}',
        brand: info.brand,
        packageName: packageInfo.packageName,
        shortVer: packageInfo.buildNumber,
      );
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
      sysInfo['os'] = 'iOS';
      sysInfo['systemVersion'] = info.systemVersion;
      sysInfo['machine'] = info.utsname.machine;
      AppInfoModule.instance.sysInfo = SysInfo.iOS(
        systemVersion: info.systemVersion ?? "",
        device: info.utsname.machine ?? "",
        brand: info.name ?? "",
        packageName: packageInfo.packageName,
        shortVer: packageInfo.buildNumber,
      );
    }
  }

  @override
  Future<void> unloadModule() async {}
}
