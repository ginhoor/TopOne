import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/download_service+task.dart';
import 'package:top_one/service/download_service.dart';

const _isolatePortServerName = "history_downloader_send_port";

class TaskModelWhereResult {
  int index;
  TaskModel item;
  TaskModelWhereResult({required this.index, required this.item});
}

class HistoryPageVM extends ChangeNotifier {
  final _port = ReceivePort();

  List<TaskModel> items = [];
  // TaskModel? getItem(String taskId) {
  //   return items.firstWhereOrNull((item) => item.taskId == taskId);
  // }

  TaskModelWhereResult? findItem(String taskId) {
    for (int i = 0; i < items.length; i++) {
      var item = items[i];
      if (item.taskId == taskId) return TaskModelWhereResult(index: i, item: item);
    }
    return null;
  }

  bool inlineadLoaded = false;
  void setInlineadLoaded() {
    if (inlineadLoaded) return;
    inlineadLoaded = true;
    notifyListeners();
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
    await EasyLoading.show(dismissOnTap: false);
    items = await DownloadService.instance.loadTasks();
    notifyListeners();
    await EasyLoading.dismiss();
  }

  Future<DownloadTask?> findCompletedTask(String taskId) async {
    var match = findItem(taskId);
    if (match == null) return null;
    var item = match.item;
    if (item.status != DownloadTaskStatus.complete) return null;
    return DownloadService.instance.findCompletedTask(taskId);
  }

  Future<bool> createDownloadTask(TTResult result) async {
    final model = await DownloadService.instance.createDownloadTask(result);
    if (model == null) return false;
    items.insert(0, model);
    notifyListeners();
    return true;
  }

  Future<void> pauseDownloadTask(String taskId) async {
    await DownloadService.instance.pauseDownloadTask(taskId);
  }

  Future<void> resumeDownloadTask(String taskId) async {
    await EasyLoading.show(dismissOnTap: false);
    final newTaskId = await DownloadService.instance.resumeDownloadTask(taskId);
    if (newTaskId != null) _updateTaskId(taskId, newTaskId);
    await EasyLoading.dismiss();
  }

  Future<void> retryDownloadTask(String taskId) async {
    await EasyLoading.show(dismissOnTap: false);
    final newTaskId = await DownloadService.instance.retryDownloadTask(taskId);
    if (newTaskId != null) {
      _updateTaskId(taskId, newTaskId);
    }
    await EasyLoading.dismiss();
  }

  void _updateTaskId(String taskId, String newTaskId) {
    var match = findItem(taskId);
    if (match == null) return;
    var item = match.item;
    var newItem = match.item.copyWith();
    newItem.taskId = newTaskId;
    items.remove(item);
    items.insert(match.index, newItem);
    notifyListeners();
  }

  void _updateDownloadInfo(String taskId, DownloadTaskStatus status, int progress) {
    var match = findItem(taskId);
    if (match == null) return;
    var item = match.item;
    var newItem = match.item.copyWith();
    newItem.status = status;
    newItem.progress = progress;
    items.remove(item);
    items.insert(match.index, newItem);
    notifyListeners();
  }

  Future<void> deleteDownloadTask(String taskId) async {
    await EasyLoading.show(dismissOnTap: false);
    await DownloadService.instance.deleteDownloadTask(taskId);
    var match = findItem(taskId);
    if (match == null) return;
    var item = match.item;
    items.remove(item);
    notifyListeners();
    await EasyLoading.dismiss();
  }

  void registerDownloaderCallback() {
    FlutterDownloader.registerCallback(downloadCallback, step: 5);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    logDebug('Callback on background isolate: '
        'task ($id) is in status ($status) and process ($progress)');
    IsolateNameServer.lookupPortByName(_isolatePortServerName)?.send([id, status, progress]);
  }

  void bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, _isolatePortServerName);
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final statusValue = data[1] as int;
      final status = DownloadTaskStatus(statusValue);

      final progress = data[2] as int;
      logDebug('Callback on UI isolate: '
          'task ($taskId) is in status ($status) and process ($progress)');
      _updateDownloadInfo(taskId, status, progress);
    });
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(_isolatePortServerName);
  }
}
