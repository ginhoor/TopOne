import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/service/download_service+task.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/tool/shared_preferences_helper.dart';
import 'package:top_one/tool/store.dart';
import 'package:top_one/tool/string.dart';
import 'package:top_one/tool/time.dart';

const _isolatePortServerName = "index_downloader_send_port";

class IndexScreenVM extends ChangeNotifier {
  double topBarOpacity = 0.0;

  final _port = ReceivePort();

  TaskModel? currentTask;

  // List<TaskModel> items = [];
  String itemsVersion = "";
  void updateItemsVersion() {
    itemsVersion = generateRandomString(5);
  }

  // TaskModel? getItem(String taskId) {
  //   return items.firstWhereOrNull((item) => item.taskId == taskId);
  // }

  Future<DownloadTask?> findCompletedTask(String taskId) async {
    // var item = getItem(taskId);
    // if (item == null) return null;
    // if (item.status != DownloadTaskStatus.complete) return null;
    return DownloadService().findCompletedTask(taskId);
  }

  Future<bool> createDownloadTask(TTResult result) async {
    final model = await DownloadService().createDownloadTask(result);
    if (model == null) return false;
    currentTask = model;
    updateItemsVersion();
    notifyListeners();
    return true;
  }

  pauseDownloadTask(String taskId) async {
    await DownloadService().pauseDownloadTask(taskId);
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
    if (currentTask == null) return;
    currentTask!.taskId = newTaskId;
    updateItemsVersion();
    notifyListeners();
  }

  _updateDownloadInfo(String taskId, DownloadTaskStatus status, int progress) {
    if (currentTask == null) return;
    currentTask!
      ..status = status
      ..progress = progress;
    if (status == DownloadTaskStatus.complete) {
      AnalyticsService().logEvent(AnalyticsEvent.completeDownload);
      const key = SharedPreferenceKeys.latest_rate_date;
      if (SharedPreferencesHelper().getInt(key) == null) {
        showRateView();
        SharedPreferencesHelper().setInt(key, currentMilliseconds());
      }
    }
    updateItemsVersion();
    notifyListeners();
  }

  updateTopBarOpacity(double topBarOpacity) {
    this.topBarOpacity = topBarOpacity;
    notifyListeners();
  }

  deleteDownloadTask(String taskId) async {
    await EasyLoading.show();
    await DownloadService().deleteDownloadTask(taskId);
    if (currentTask != null) currentTask = null;
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
