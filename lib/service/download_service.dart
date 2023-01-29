import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:top_one/tool/logger.dart';

class DownloadService {
  static const String BASE_URL_PROD = 'https://imweb.bianfeng.com';
  static const String BASE_URL_DEV = 'https://imweb-dev.daqun.team';
  static const String KNOWLEDGE_ENTRANCE =
      "https://daqun-miniapp.imeete.com/think_tank/#/mobile/search";

  bool hasGranted = false;
  DownloadService._internal();

  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;

  Future<void> setup() async {
    await prepareSaveDir();
  }

  Future<void> prepareSaveDir() async {
    final hasGranted = await checkPermission();
    if (!hasGranted) {
      return;
    }
    var localPath = (await DownloadService().getSavedDirPath());
    final savedDir = Directory(localPath);
    if (!savedDir.existsSync()) {
      await savedDir.create();
    }
  }

  Future<String> getSavedDirPath() async {
    String externalStorageDirPath = "";

    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (err, st) {
        logDebug('failed to get downloads path: $err, $st');

        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path ?? "";
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    logDebug('get downloads path: $externalStorageDirPath');
    return externalStorageDirPath;
  }

  Future<bool> checkPermission() async {
    if (Platform.isIOS) {
      hasGranted = true;
      return true;
    }
    if (Platform.isAndroid) {
      var pList = [Permission.storage];
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 30) {
        pList.add(Permission.manageExternalStorage);
      }
      for (Permission p in pList) {
        logDebug("Permission status $p ${p.status.isGranted}");
        if (!await p.request().isGranted) {
          hasGranted = false;
          return false;
        }
      }
      hasGranted = true;
      return true;
    }
    hasGranted = false;
    return false;
  }
}
