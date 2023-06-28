import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/manager/download_task_manager.dart';
import 'package:top_one/manager/photo_library_manager.dart';
import 'package:top_one/manager/store_manager.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/view/hud_easy_loading.dart';

enum DownloadTaskVMMode {
  single("single"),
  normal("normal");

  const DownloadTaskVMMode(this.value);
  final String value;
}

class DownloadTaskVM extends ChangeNotifier {
  DownloadTaskVMMode mode = DownloadTaskVMMode.single;

  List<TaskModel> items = [];
  StreamSubscription<TaskUpdate>? _subscription;
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void addOB() {
    _subscription = DownloadTaskManager.instance.notificationManager.notificationStream.listen((update) {
      var task = update.task;
      switch (update) {
        case TaskStatusUpdate status:
          logDebug('[task] Status update ${status.task.taskId} status: ${status.status}');

          /// progress需要有进度时才能回调，有延迟
          _updateTask(task, status.status, null);
        case TaskProgressUpdate progress:
          var progressVal = progress.progress;
          logDebug(
              '[task] Progress update ${progress.task.taskId} progress: $progressVal size ${progress.expectedFileSize}');
          switch (progressVal) {
            case progressComplete:
              _updateTask(task, TaskStatus.complete, null);
              break;
            case progressFailed:
              _updateTask(task, TaskStatus.failed, null);
              break;
            case progressCanceled:
              _updateTask(task, TaskStatus.canceled, null);
              break;
            case progressNotFound:
              _updateTask(task, TaskStatus.notFound, null);
              break;
            case progressWaitingToRetry:
              _updateTask(task, TaskStatus.waitingToRetry, null);
              break;
            case progressPaused:
              _updateTask(task, TaskStatus.paused, null);
              break;
            default:
              _updateTask(task, TaskStatus.running, (progressVal * 100).toInt());
              break;
          }
      }
    });
  }

  void _updateTask(Task task, TaskStatus? status, int? progress) {
    var taskId = task.taskId;
    if (items.isEmpty) return;
    TaskModel? currentTask = findTask(taskId);
    if (currentTask == null) return;
    if (progress != null) currentTask.progress = progress;
    if (status != null) currentTask.status = status;

    if (status == TaskStatus.complete) {
      AnalyticsService.instance.logEvent(AnalyticsEvent.completeDownload);
      task.filePath().then((path) async {
        var exist = await File(path).exists();
        if (!exist) return;
        PhotoLibraryManager.instance.saveVideo(path);
      });

      if (mode == DownloadTaskVMMode.single) {
        StoreManager.instance.showInAppReview();
        // 记录红标
        AppPreference.instance.setInt(AppPreferenceKey.hasNewHistoryDate.value, currentMilliseconds);
      }
    }
    notifyListeners();
  }

  Future<void> loadTasks() async {
    items = await DownloadTaskManager.instance.loadTasks();
    // 创建时间倒序
    items.sort((a, b) => b.startTime.compareTo(a.startTime));
    notifyListeners();
  }

  TaskModel? findTask(String taskId) {
    TaskModel? currentTask = items.firstWhereOrNull((element) => element.taskId == taskId);
    return currentTask;
  }

  Future<bool> createDownloadTask(TTResult result) async {
    final model = await DownloadTaskManager.instance.createDownloadTask(result);
    if (model == null) return false;
    if (mode == DownloadTaskVMMode.single) {
      items = [model];
    } else {
      items.add(model);
    }
    notifyListeners();
    return true;
  }

  Future<void> pauseDownloadTask(String taskId) async {
    await HUDEasyLoading.showLoading();
    await DownloadTaskManager.instance.pauseDownloadTask(taskId);
    await HUDEasyLoading.dismiss();
  }

  Future<void> resumeDownloadTask(String taskId) async {
    await HUDEasyLoading.showLoading();
    await DownloadTaskManager.instance.resumeDownloadTask(taskId);
    await HUDEasyLoading.dismiss();
    logDebug("[task] resume done");
  }

  Future<void> retryDownloadTask(String taskId) async {
    await HUDEasyLoading.showLoading();
    await DownloadTaskManager.instance.resumeDownloadTask(taskId);
    await HUDEasyLoading.dismiss();
  }

  Future<void> deleteDownloadTask(String taskId) async {
    await HUDEasyLoading.showLoading();
    await DownloadTaskManager.instance.deleteDownloadTask(taskId);
    items.removeWhere((element) => element.taskId == taskId);
    await HUDEasyLoading.dismiss();
    notifyListeners();
  }

  Future<void> deleteAllCompletedDownloadTask() async {
    if (items.isEmpty) return;
    await HUDEasyLoading.showLoading();
    var toRemove = [];
    for (var task in items) {
      var taskId = task.taskId;
      var exist = await DownloadTaskManager.instance.findCompletedTask(taskId);
      if (exist != null) {
        await DownloadTaskManager.instance.deleteDownloadTask(taskId);
        toRemove.add(task);
      }
    }
    items.removeWhere((e) => toRemove.contains(e));
    await HUDEasyLoading.dismiss();
    notifyListeners();
  }
}
