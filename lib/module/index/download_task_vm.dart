import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:top_one/app/app_preference.dart';
import 'package:top_one/manager/download_task_manager.dart';
import 'package:top_one/manager/photo_library_manager.dart';
import 'package:top_one/manager/store_manager.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';

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
          debugPrint('[task] Status update for ${status.task} with status ${status.status}');
          _updateTask(task, status.status, null);

        case TaskProgressUpdate progress:
          debugPrint('[task] Progress update for ${progress.task} with progress ${progress.progress} '
              'and expected file size ${progress.expectedFileSize}');
          _updateTask(task, null, (progress.progress * 100).toInt());
      }
    });
  }

  void _updateTask(Task task, TaskStatus? status, int? progress) {
    var taskId = task.taskId;
    if (items.isEmpty) return;
    TaskModel? currentTask = items.firstWhereOrNull((element) => element.taskId == taskId);
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
    notifyListeners();
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
    await DownloadTaskManager.instance.pauseDownloadTask(taskId);
  }

  Future<void> resumeDownloadTask(String taskId) async {
    await DownloadTaskManager.instance.resumeDownloadTask(taskId);
  }

  Future<void> retryDownloadTask(String taskId) async {
    await DownloadTaskManager.instance.resumeDownloadTask(taskId);
  }

  Future<void> deleteDownloadTask(String taskId) async {
    await DownloadTaskManager.instance.deleteDownloadTask(taskId);
  }
}
