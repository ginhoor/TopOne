import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:gh_tool_package/extension/string.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:path/path.dart' as path;
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/service/download_service+task.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/service/photo_library_service.dart';
import 'package:top_one/tool/store_kit.dart';

const _isolatePortServerName = "index_downloader_send_port";

class IndexPageVM extends ChangeNotifier {
  double topBarOpacity = 0.0;

  final _port = ReceivePort();

  TaskModel? currentTask;

  String topBarDataVersion = "";
  void updateTopBarDataVersion() {
    topBarDataVersion = generateRandomString(5);
  }

  bool inlineadLoaded = false;
  void setInlineadLoaded() {
    if (inlineadLoaded) return;
    inlineadLoaded = true;
    notifyListeners();
  }

  Future<DownloadTask?> findCompletedTask(String taskId) async {
    return DownloadService.instance.findCompletedTask(taskId);
  }

  Future<bool> createDownloadTask(TTResult result) async {
    final model = await DownloadService.instance.createDownloadTask(result);
    if (model == null) return false;
    currentTask = model;
    notifyListeners();
    return true;
  }

  Future<void> pauseDownloadTask(String taskId) async {
    await DownloadService.instance.pauseDownloadTask(taskId);
  }

  Future<void> resumeDownloadTask(String taskId) async {
    await EasyLoading.show(dismissOnTap: false);
    final newTaskId = await FlutterDownloader.resume(taskId: taskId);
    if (newTaskId == null) {
      await EasyLoading.dismiss();
      return;
    }
    AnalyticsService().logEvent(AnalyticsEvent.resumeDownload);
    _updateTaskId(taskId, newTaskId);
    await EasyLoading.dismiss();
  }

  Future<void> retryDownloadTask(String taskId) async {
    await EasyLoading.show(dismissOnTap: false);
    final newTaskId = await FlutterDownloader.retry(taskId: taskId);
    if (newTaskId == null) {
      await EasyLoading.dismiss();
      return;
    }
    AnalyticsService().logEvent(AnalyticsEvent.retryDownload);
    _updateTaskId(taskId, newTaskId);
    await EasyLoading.dismiss();
  }

  void _updateTaskId(String taskId, String newTaskId) {
    if (currentTask == null) return;
    var newTaskModel = currentTask?.copyWith();
    if (newTaskModel == null) return;
    newTaskModel.taskId = newTaskId;
    currentTask = newTaskModel;
    notifyListeners();
  }

  void _updateDownloadInfo(String taskId, DownloadTaskStatus status, int progress) {
    if (currentTask == null) return;
    var newTaskModel = currentTask?.copyWith();
    if (newTaskModel == null) return;
    newTaskModel
      ..status = status
      ..progress = progress;
    currentTask = newTaskModel;
    if (status == DownloadTaskStatus.complete) {
      AnalyticsService.instance.logEvent(AnalyticsEvent.completeDownload);
      DownloadService.instance.findCompletedTask(taskId).then((value) {
        if (value == null) return;
        var filePath = path.join(value.savedDir, value.filename);
        PhotoLibraryService().saveVideo(filePath);
      });
      showCustomRateView(null, AppPreferenceKey.latest_download_complete_rate_date);
      // 记录红标
      AppPreference.instance.setInt(AppPreferenceKey.has_new_history_date, currentMilliseconds());
    }
    notifyListeners();
  }

  void updateTopBarOpacity(double topBarOpacity) {
    this.topBarOpacity = topBarOpacity;
    notifyListeners();
  }

  Future<void> deleteDownloadTask(String taskId) async {
    await EasyLoading.show(dismissOnTap: false);
    await DownloadService.instance.deleteDownloadTask(taskId);
    if (currentTask != null) currentTask = null;
    notifyListeners();
    await EasyLoading.dismiss();
  }

  void registerDownloaderCallback() {
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
  }

  @pragma('vm:entry-point')
  static downloadCallback(String id, int status, int progress) {
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
      final status = DownloadTaskStatus(data[1] as int);
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
