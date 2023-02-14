import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:top_one/data/tt_result_datasource.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/download_service.dart';
import 'package:uuid/uuid.dart';

import 'analytics/analytics_event.dart';
import 'analytics/analytics_service.dart';

extension Metadata on DownloadService {
  Future<List<TaskModel>> loadTasks() async {
    var existTasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task ORDER BY time_created DESC");
    if (existTasks == null || existTasks.isEmpty) return [];

    List<TaskModel> models = [];
    for (var task in existTasks) {
      var taskId = task.taskId;
      var metaData = await TTResultDatasource().query(taskId);
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
    return models;
  }

  Future<DownloadTask?> findCompletedTask(String taskId) async {
    var results = await FlutterDownloader.loadTasksWithRawQuery(
        query: "SELECT * FROM task WHERE task_id == '$taskId'");
    if (results != null && results.isEmpty) return null;
    return results!.first;
  }

  Future<TaskModel?> createDownloadTask(TTResult result) async {
    if (result.video == null) return null;
    var savedDir = await DownloadService().getSavedDirPath();
    final taskId = await FlutterDownloader.enqueue(
      url: result.video!,
      fileName: '${const Uuid().v1()}.mp4',
      headers: {}, // optional: header send with url (auth token etc)
      savedDir: savedDir,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          false, // click on notification to open downloaded file (for Android)
    );
    if (taskId == null) return null;
    AnalyticsService().logEvent(AnalyticsEvent.createDownload);
    final model = TaskModel(metaData: result, taskId: taskId);
    TTResultDatasource().save(taskId, result);
    return model;
  }

  pauseDownloadTask(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
    AnalyticsService().logEvent(AnalyticsEvent.pauseDownload);
  }

  Future<String?> resumeDownloadTask(String taskId) async {
    final newTaskId = await FlutterDownloader.resume(taskId: taskId);
    if (newTaskId == null) return null;
    AnalyticsService().logEvent(AnalyticsEvent.resumeDownload);
    return newTaskId;
  }

  Future<String?> retryDownloadTask(String taskId) async {
    final newTaskId = await FlutterDownloader.retry(taskId: taskId);
    if (newTaskId == null) return null;
    AnalyticsService().logEvent(AnalyticsEvent.retryDownload);
    return newTaskId;
  }

  deleteDownloadTask(String taskId) async {
    await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
    await TTResultDatasource().delete(taskId);
    AnalyticsService().logEvent(AnalyticsEvent.deleteDownload);
  }
}
