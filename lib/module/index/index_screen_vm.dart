import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as path;
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics_event.dart';
import 'package:top_one/service/analytics_service.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/string.dart';

const _isolatePortServerName = "index_downloader_send_port";

class IndexScreenVM extends ChangeNotifier {
  double topBarOpacity = 0.0;
  List<DownloadTask> downloaderTasks = [];
  final _port = ReceivePort();

  List<TaskModel> items = [];
  String itemsVersion = "";
  void updateItemsVersion() {
    itemsVersion = generateRandomString(5);
  }

  TaskModel? getItem(String taskId) {
    return items.firstWhereOrNull((item) => item.taskId == taskId);
  }

  loadTasks() async {
    await EasyLoading.show();
    var existTasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task ORDER BY time_created DESC");
    if (existTasks == null || existTasks.isEmpty) {
      await EasyLoading.dismiss();
      return;
    }
    List<TaskModel> models = [];
    for (var task in existTasks) {
      var taskId = task.taskId;
      var metaData = await _queryMetaData(taskId);
      if (metaData == null) {
        deleteDownloadTask(taskId);
        continue;
      }
      var model = TaskModel(
          metaData: metaData,
          taskId: taskId,
          progress: task.progress,
          status: task.status);
      model.startTime = task.timeCreated;
      models.add(model);
    }
    items = models;
    updateItemsVersion();
    notifyListeners();
    await EasyLoading.dismiss();
  }

  Future<DownloadTask?> findCompletedTask(String taskId) async {
    var item = getItem(taskId);
    if (item == null) return null;
    if (item.status != DownloadTaskStatus.complete) return null;
    var results = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE task_id == '$taskId'");
    if (results != null && results.isEmpty) return null;
    return results!.first;
  }

  Future<bool> createDownloadTask(TTResult result) async {
    if (result.video == null) return false;
    var savedDir = await DownloadService().getSavedDirPath();
    final taskId = await FlutterDownloader.enqueue(
      url: result.video!,
      headers: {}, // optional: header send with url (auth token etc)
      savedDir: savedDir,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          false, // click on notification to open downloaded file (for Android)
    );
    if (taskId == null) return false;
    AnalyticsService().logEvent(AnalyticsEvent.createDownload);
    final model = TaskModel(metaData: result, taskId: taskId);
    items.insert(0, model);
    _saveMetaData(model.taskId, result);
    updateItemsVersion();
    notifyListeners();

    return true;
  }

  pauseDownloadTask(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
    AnalyticsService().logEvent(AnalyticsEvent.pauseDownload);
  }

  resumeDownloadTask(String taskId) async {
    await EasyLoading.show();
    final newTaskId = await FlutterDownloader.resume(taskId: taskId);
    if (newTaskId == null) {
      await EasyLoading.dismiss();
      return;
    }
    AnalyticsService().logEvent(AnalyticsEvent.resumeDownload);
    _updateTaskId(taskId, newTaskId);
    await EasyLoading.dismiss();
  }

  retryDownloadTask(String taskId) async {
    await EasyLoading.show();
    final newTaskId = await FlutterDownloader.retry(taskId: taskId);
    if (newTaskId == null) {
      await EasyLoading.dismiss();
      return;
    }
    AnalyticsService().logEvent(AnalyticsEvent.retryDownload);
    _updateTaskId(taskId, newTaskId);
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

    if (status == DownloadTaskStatus.complete) {
      AnalyticsService().logEvent(AnalyticsEvent.completeDownload);
    }
    notifyListeners();
  }

  updateTopBarOpacity(double topBarOpacity) {
    this.topBarOpacity = topBarOpacity;
    notifyListeners();
  }

  deleteDownloadTask(String taskId) async {
    await EasyLoading.show();
    await FlutterDownloader.remove(
      taskId: taskId,
      shouldDeleteContent: true,
    );
    var item = getItem(taskId);
    if (item == null) {
      await EasyLoading.dismiss();
      return;
    }
    AnalyticsService().logEvent(AnalyticsEvent.deleteDownload);
    items.remove(item);
    _deleteMetaData(taskId);
    updateItemsVersion();
    notifyListeners();
    await EasyLoading.dismiss();
  }

  Future<TTResult?> _queryMetaData(String taskId) async {
    final dirPath = await DownloadService().getMetaDataDirPath();
    final filePath = path.join(dirPath, taskId);
    final file = File(filePath);
    var fileExists = file.existsSync();
    if (fileExists) {
      var fileContent = json.decode(file.readAsStringSync());
      return TTResult.fromJson(fileContent);
    }
    return null;
  }

  _saveMetaData(String taskId, TTResult result) async {
    final dirPath = await DownloadService().getMetaDataDirPath();
    final filePath = path.join(dirPath, taskId);
    final file = File(filePath);
    file.createSync();
    var content = result.toJson();
    file.writeAsStringSync(json.encode(content));
  }

  _deleteMetaData(String taskId) async {
    final dirPath = await DownloadService().getMetaDataDirPath();
    final filePath = path.join(dirPath, taskId);
    final file = File(filePath);
    file.delete();
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
