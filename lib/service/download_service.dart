import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:top_one/tool/logger.dart';

class DownloadService {
  // static const String BASE_URL_PROD = 'https://imweb.bianfeng.com';
  // static const String BASE_URL_DEV = 'https://imweb-dev.daqun.team';
  // static const String KNOWLEDGE_ENTRANCE =
  //     "https://daqun-miniapp.imeete.com/think_tank/#/mobile/search";

  bool hasGranted = false;
  DownloadService._internal();

  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;

  Future<void> setupDirs() async {
    await prepareSaveDir();
    await prepareMetaSaveDir();
  }

  Future<void> prepareSaveDir() async {
    final hasGranted = await checkPermission();
    if (!hasGranted) return;
    var localPath = await getSavedDirPath();
    final savedDir = Directory(localPath);
    logDebug('get downloads path: $savedDir');
    if (!savedDir.existsSync()) await savedDir.create();
  }

  Future<void> prepareMetaSaveDir() async {
    var localPath = await getMetaDataDirPath();
    final savedDir = Directory(localPath);
    logDebug('get meta data path: $savedDir');
    if (!savedDir.existsSync()) await savedDir.create();
  }

  Future<String> getExternalStorageDirPath() async {
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
    return externalStorageDirPath;
  }

  Future<String> getSavedDirPath() async {
    var savedDirPath =
        path.join(await getExternalStorageDirPath(), 'Downloads');
    var dir = Directory(savedDirPath);
    try {
      bool exists = await dir.exists();
      if (!exists) await dir.create();
    } catch (e) {
      logError(e.toString());
    }
    return savedDirPath;
  }

  Future<String> getMetaDataDirPath() async {
    var savedDirPath = path.join(await getExternalStorageDirPath(), 'MetaData');
    var dir = Directory(savedDirPath);
    try {
      bool exists = await dir.exists();
      if (!exists) await dir.create();
    } catch (e) {
      logError(e.toString());
    }
    return savedDirPath;
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
        if (!await p.request().isGranted) {
          hasGranted = false;
          logDebug("Permission status $p false");
          return false;
        }
      }
      logDebug("Permission status $pList true");
      hasGranted = true;
      return true;
    }
    hasGranted = false;
    return false;
  }
}
