import 'package:top_one/manager/download_task_manager.dart';

extension Setup on DownloadTaskManager {
  // Future<void> prepareSaveDir() async {
  //   var localPath = await getSavedDirPath();
  //   final savedDir = Directory(localPath);
  //   logDebug('get downloads path: $savedDir');
  //   if (!savedDir.existsSync()) await savedDir.create();
  // }

  // Future<String> getSavedDirPath() async {
  //   var savedDirPath = path.join(await getExternalStorageDirPath(), 'Downloads');
  //   var dir = Directory(savedDirPath);
  //   try {
  //     bool exists = await dir.exists();
  //     if (!exists) await dir.create();
  //   } catch (e) {
  //     logError(e.toString());
  //   }
  //   return savedDirPath;
  // }

  // Future<String> getExternalStorageDirPath() async {
  //   String externalStorageDirPath = "";
  //   if (Platform.isAndroid) {
  //     try {
  //       final directory = await getApplicationDocumentsDirectory();
  //       externalStorageDirPath = directory.path;
  //       // externalStorageDirPath = await AndroidPathProvider.downloadsPath;
  //     } catch (err, st) {
  //       logDebug('failed to get downloads path: $err, $st');

  //       final directory = await getExternalStorageDirectory();
  //       externalStorageDirPath = directory?.path ?? "";
  //     }
  //   } else if (Platform.isIOS) {
  //     externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
  //   }
  //   return externalStorageDirPath;
  // }
}
