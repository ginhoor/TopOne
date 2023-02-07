import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/download_service+task.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/string.dart';

const _isolatePortServerName = "history_downloader_send_port";

class HistoryScreenVM extends ChangeNotifier {
  final _port = ReceivePort();

  List<TaskModel> items = [];
  String itemsVersion = "";
  void updateItemsVersion() {
    itemsVersion = generateRandomString(5);
  }

  TaskModel? getItem(String taskId) {
    return items.firstWhereOrNull((item) => item.taskId == taskId);
  }

/**
 * CREATE TABLE `task` (
  `id`  INTEGER PRIMARY KEY AUTOINCREMENT,
  `task_id` VARCHAR ( 256 ),
  `url` TEXT,
  `status`  INTEGER DEFAULT 0,
  `progress`  INTEGER DEFAULT 0,
  `file_name` TEXT,
  `saved_dir` TEXT,
  `resumable` TINYINT DEFAULT 0,
  `headers` TEXT,
  `show_notification` TINYINT DEFAULT 0,
  `open_file_from_notification` TINYINT DEFAULT 0,
  `time_created`  INTEGER DEFAULT 0
); */
  loadTasks() async {
    await EasyLoading.show();
    items = await DownloadService().loadTasks();
    updateItemsVersion();
    notifyListeners();
    await EasyLoading.dismiss();
  }

  Future<DownloadTask?> findCompletedTask(String taskId) async {
    var item = getItem(taskId);
    if (item == null) return null;
    if (item.status != DownloadTaskStatus.complete) return null;
    return DownloadService().findCompletedTask(taskId);
  }

  Future<bool> createDownloadTask(TTResult result) async {
    final model = await DownloadService().createDownloadTask(result);
    if (model == null) return false;
    items.insert(0, model);
    updateItemsVersion();
    notifyListeners();
    return true;
  }

  pauseDownloadTask(String taskId) async {
    await DownloadService().pauseDownloadTask(taskId);
  }

  resumeDownloadTask(String taskId) async {
    await EasyLoading.show();
    final newTaskId = await DownloadService().resumeDownloadTask(taskId);
    if (newTaskId != null) {
      _updateTaskId(taskId, newTaskId);
    }
    await EasyLoading.dismiss();
  }

  retryDownloadTask(String taskId) async {
    await EasyLoading.show();
    final newTaskId = await DownloadService().retryDownloadTask(taskId);
    if (newTaskId != null) {
      _updateTaskId(taskId, newTaskId);
    }
    await EasyLoading.dismiss();
  }

  _updateTaskId(String taskId, String newTaskId) {
    var item = getItem(taskId);
    if (item == null) return;
    item.taskId = newTaskId;
    updateItemsVersion();
    notifyListeners();
  }

  _updateDownloadInfo(String taskId, DownloadTaskStatus status, int progress) {
    var item = getItem(taskId);
    if (item == null) return;
    item
      ..status = status
      ..progress = progress;
    updateItemsVersion();
    notifyListeners();
  }

  deleteDownloadTask(String taskId) async {
    await EasyLoading.show();
    await DownloadService().deleteDownloadTask(taskId);
    var item = getItem(taskId);
    if (item != null) items.remove(item);
    updateItemsVersion();
    notifyListeners();
    await EasyLoading.dismiss();
  }

  registerDownloaderCallback() {
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
  }

  @pragma('vm:entry-point')
  static downloadCallback(String id, DownloadTaskStatus status, int progress) {
    logDebug('Callback on background isolate: '
        'task ($id) is in status ($status) and process ($progress)');
    IsolateNameServer.lookupPortByName(_isolatePortServerName)
        ?.send([id, status, progress]);
  }

  bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, _isolatePortServerName);
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = data[1] as DownloadTaskStatus;
      final progress = data[2] as int;
      logDebug('Callback on UI isolate: '
          'task ($taskId) is in status ($status) and process ($progress)');
      _updateDownloadInfo(taskId, status, progress);
    });
  }

  unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(_isolatePortServerName);
  }
}
