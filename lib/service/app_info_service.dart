import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

String appName = "Top One";

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

class AppInfoService {
  static final AppInfoService instance = AppInfoService._instance();
  factory AppInfoService() => instance;

  late String _appVersion;
  String get appVersion => _appVersion;

  late SysInfo sysInfo;
  AppInfoService._instance() {
    _appVersion = '0.0.0';
  }

  Future<void> init() async {
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
      AppInfoService().sysInfo = SysInfo.android(
        systemVersion: '${info.version.release}-${info.version.sdkInt}',
        device: '${info.brand} ${info.model}',
        brand: info.brand,
        packageName: packageInfo.packageName,
        shortVer: packageInfo.buildNumber,
      );
    } else {
      IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
      sysInfo['os'] = 'iOS';
      sysInfo['systemVersion'] = info.systemVersion;
      sysInfo['machine'] = info.utsname.machine;
      AppInfoService().sysInfo = SysInfo.iOS(
        systemVersion: info.systemVersion ?? "",
        device: info.utsname.machine ?? "",
        brand: info.name ?? "",
        packageName: packageInfo.packageName,
        shortVer: packageInfo.buildNumber,
      );
    }
  }
}
