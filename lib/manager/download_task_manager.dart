import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tool_kit/manager/file_manager.dart';
import 'package:flutter_tool_kit/service/notification_center.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:top_one/data/download_task_storage.dart';
import 'package:top_one/data/tt_result_datasource.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:uuid/uuid.dart';

class DownloadTaskManager {
  static final DownloadTaskManager instance = DownloadTaskManager._instance();
  factory DownloadTaskManager() => instance;
  DownloadTaskManager._instance();

  final NotificationCenter<TaskUpdate> notificationManager = NotificationCenter();

  void myNotificationTapCallback(Task task, NotificationType notificationType) {
    debugPrint('Tapped notification $notificationType for taskId ${task.taskId}');
  }

  Future<void> setup() async {
    var downloader = FileDownloader(persistentStorage: DownloadTaskStorage());
    await downloader.trackTasks();
    // 状态监控
    downloader.registerCallbacks(taskNotificationTapCallback: myNotificationTapCallback);
    // downloader.configureNotificationForGroup(FileDownloader.defaultGroup,
    //     running: const TaskNotification('Download {filename}', 'File: {filename} - {progress}'),
    //     complete: const TaskNotification('Download {filename}', 'Download complete'),
    //     error: const TaskNotification('Download {filename}', 'Download failed'),
    //     paused: const TaskNotification('Download {filename}', 'Paused with metadata {metadata}'),
    //     progressBar: true);

    // 当尝试显示其第一个通知时，下载器将要求用户允许显示通知（取决于平台版本）并遵守用户选择。
    //对于Android，从API 33开始，
    //您需要将<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    //添加到应用程序的AndroidManifest.xml中。
    //此外，在Android上，您可以通过覆盖字符串
    //resourcesbgbg_downloader_cancel、
    //bg_downloader_pause、
    //bg_downloader_resume和
    //descriptionsbgbg_downloader_notification_channel_name、
    //bg_downloader_notification_channel_description
    //来本地化按钮文本。
    // 任务配置推送
    // downloader.configureNotification(
    //     // for the 'Download & Open' dog picture
    //     // which uses 'download' which is not the .defaultGroup
    //     // but the .await group so won't use the above config
    //     running: const TaskNotification('Downloading', 'file: {filename}'),
    //     progressBar: true,
    //     complete: const TaskNotification('Download {filename}', 'Download complete'),
    //     error: const TaskNotification('Download {filename}', 'Download failed'),
    //     tapOpensFile: true); // dog can also open directly from tap

    // Listen to updates and process
    // 通过收听updates流来收听下载器的更新，并集中处理这些更新。
    // 例如，以下创建一个侦听器来监控下载的状态和进度更新，然后将任务排队作为示例：
    downloader.updates.listen((update) => notificationManager.sendMessage(update));
    // 为了确保您的应用程序在后台暂停时可能发生的回调或侦听器捕获事件，请在注册回调或侦听器后立即调用
    await FileDownloader().resumeFromBackground();
  }

  Future<TaskModel?> createDownloadTask(TTResult result) async {
    AnalyticsService().logEvent(AnalyticsEvent.createDownload);

    if (result.video == null) return null;

    /// 要安排失败请求/任务的自动重试（带有指数回退），请将retries字段设置为1到10之间的整数。
    /// 正常Task（无需重试）将遵循从enqueued->running->complete（或notFound）的状态更新。
    /// 如果已设置retries且任务失败，
    /// 则序列将被enqueued->running->waitingToRetry->enqueued->running->complete（如果第二次尝试成功，或根据需要进行更多重试）。
    /// Request的行为类似，除非它不提供中间状态更新。
    final task = DownloadTask(
      url: result.video!,
      filename: '${Uuid().v1()}.mp4',
      headers: {'myHeader': 'value'},

      updates: Updates.statusAndProgress, // request status and progress updates
      // requiresWiFi: true,
      retries: 0,
      allowPause:
          true, //在Android上，下载默认限制为9分钟，之后下载将以TaskStatus.failed结束。为了允许更长时间的下载，请将DownloadTask.allowPause字段设置为true：如果任务过时，它将暂停并自动恢复，最终下载整个文件。
      // metaData: 'data for me'
    );

    final successfullyEnqueued = await FileDownloader().enqueue(task);
    if (!successfullyEnqueued) return null;

    var taskId = task.taskId;
    var filePath = await task.filePath();
    final model = TaskModel(metaData: result, startTime: currentMilliseconds, taskId: taskId, filePath: filePath);
    TTResultDatasource().save(taskId, result);

    return model;
  }

  Future<List<TaskModel>> loadTasks() async {
    var records = await FileDownloader().database.allRecords();
    List<TaskModel> models = [];
    for (var record in records) {
      var taskId = record.taskId;
      var filePath = await record.task.filePath();
      var metaData = await TTResultDatasource().query(taskId);
      if (metaData == null) {
        deleteDownloadTask(taskId);
        continue;
      }
      var model = TaskModel(
          metaData: metaData,
          startTime: currentMilliseconds,
          taskId: taskId,
          filePath: filePath,
          progress: (record.progress * 100).toInt(),
          status: record.status);

      model.startTime = record.task.creationTime.millisecondsSinceEpoch;
      models.add(model);
    }

    return models;
  }

  Future<void> deleteDownloadTask(String taskId) async {
    AnalyticsService().logEvent(AnalyticsEvent.deleteDownload);
    var exist = await FileDownloader().database.recordForId(taskId);
    if (exist != null) {
      var filepath = await exist.task.filePath();
      await FileManager.delete(filepath);
      await FileDownloader().database.deleteRecordWithId(taskId);
    }
    await TTResultDatasource().delete(taskId);
  }

  Future<TaskRecord?> getRecord(String taskId) async {
    return FileDownloader().database.recordForId(taskId);
  }

  Future<DownloadTask?> getDownloadTask(String taskId) async {
    var exist = await FileDownloader().database.recordForId(taskId);
    if (exist == null) return null;
    var task = exist.task as DownloadTask?;
    if (task == null) return null;
    return task;
  }

  Future<DownloadTask?> resumeDownloadTask(String taskId) async {
    AnalyticsService().logEvent(AnalyticsEvent.resumeDownload);
    var task = await getDownloadTask(taskId);
    if (task == null) return null;
    var success = await FileDownloader().resume(task);
    if (!success) return null;
    return task;
  }

  Future<DownloadTask?> pauseDownloadTask(String taskId) async {
    AnalyticsService().logEvent(AnalyticsEvent.pauseDownload);
    var task = await getDownloadTask(taskId);
    if (task == null) return null;
    var success = await FileDownloader().pause(task);
    if (!success) return null;
    return task;
  }

  Future<bool> cancelDownloadTask(String taskId) async {
    return FileDownloader().cancelTaskWithId(taskId);
  }

  Future<TaskRecord?> findCompletedTask(String taskId) async {
    var exist = await FileDownloader().database.recordForId(taskId);
    if (exist == null) return null;
    if (exist.status != TaskStatus.complete) return null;
    return exist;
  }
}
