import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/module/index/index_screen.dart';
import 'package:top_one/module/index/view/download_list_item.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/tool/logger.dart';

extension HandleDownload on IndexScreen {
  handleItemTap(BuildContext context, DownloadInfo? task) async {
    final success = await openDownloadedFile(task);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot open this file'),
        ),
      );
    }
  }

  Future<void> handleItemActionTap(
      BuildContext context, DownloadInfo task) async {
    if (task.status == DownloadTaskStatus.undefined) {
      await requestDownload(task);
    } else if (task.status == DownloadTaskStatus.running) {
      await pauseDownload(task);
    } else if (task.status == DownloadTaskStatus.paused) {
      await resumeDownload(task);
    } else if (task.status == DownloadTaskStatus.complete ||
        task.status == DownloadTaskStatus.canceled) {
      await handleDelete(context, task);
    } else if (task.status == DownloadTaskStatus.failed) {
      await retryDownload(task);
    }
  }

  Future<void> handleDelete(BuildContext context, DownloadInfo task) async {
    await FlutterDownloader.remove(
      taskId: task.taskId!,
      shouldDeleteContent: true,
    );
  }

  Future<void> requestDownload(DownloadInfo task) async {
    var savedDir = await DownloadService().getSavedDirPath();
    task.taskId = await FlutterDownloader.enqueue(
      url: task.link,
      // headers: {'auth': 'test_for_sql_encoding'},
      headers: {},
      savedDir: savedDir,
      saveInPublicStorage: true,
    );
  }

  Future<void> pauseDownload(DownloadInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  Future<void> resumeDownload(DownloadInfo task) async {
    final newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  Future<void> retryDownload(DownloadInfo task) async {
    final newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  Future<bool> openDownloadedFile(DownloadInfo? task) async {
    final taskId = task?.taskId;
    if (taskId == null) {
      return false;
    }
    return FlutterDownloader.open(taskId: taskId);
  }

  Future<bool> checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }
    if (Platform.isAndroid) {
      var pList = [Permission.storage];
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 30) {
        pList.add(Permission.manageExternalStorage);
      }
      for (Permission p in pList) {
        logDebug("Permission status $p ${p.status.isGranted}");
        if (!await p.request().isGranted) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  DownloadListItem buildTaskItem(BuildContext context, TaskModel item) {
    return DownloadListItem(
      data: item,
      onTap: (task) async {
        await handleItemTap(context, task);
      },
      onActionTap: (task) async {
        await handleItemActionTap(context, task);
      },
      onCancel: (task) async {
        await handleDelete(context, task);
      },
    );
  }

  Widget buildNoPermissionWarning() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Grant storage permission to continue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 18),
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: _retryRequestPermission,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _retryRequestPermission() async {
    final hasGranted = await DownloadService().checkPermission();
    if (hasGranted) {
      await _prepareSaveDir();
    }
    return hasGranted;
  }

  Future<void> _prepareSaveDir() async {
    var localPath = (await DownloadService().getSavedDirPath())!;
    final savedDir = Directory(localPath);
    if (!savedDir.existsSync()) {
      await savedDir.create();
    }
  }
}
