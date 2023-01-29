import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/module/index/index_screen.dart';
import 'package:top_one/service/download_service.dart';
import 'package:top_one/tool/logger.dart';

extension HandleDownload on IndexScreen {
  Future<void> handleItemActionTap(TaskModel model) async {
    if (model.status == DownloadTaskStatus.undefined) {
      await requestDownload(model);
    } else if (model.status == DownloadTaskStatus.running) {
      await pauseDownload(model);
    } else if (model.status == DownloadTaskStatus.paused) {
      await resumeDownload(model);
    } else if (model.status == DownloadTaskStatus.complete ||
        model.status == DownloadTaskStatus.canceled) {
      await handleDelete(model);
    } else if (model.status == DownloadTaskStatus.failed) {
      await retryDownload(model);
    }
  }

  Future<void> handleDelete(TaskModel model) async {
    await FlutterDownloader.remove(
      taskId: model.taskId,
      shouldDeleteContent: true,
    );
  }

  Future<void> requestDownload(TaskModel model) async {
    // var savedDir = await DownloadService().getSavedDirPath();
    // final taskId = await FlutterDownloader.enqueue(
    //   url: model.video,
    //   // headers: {'auth': 'test_for_sql_encoding'},
    //   headers: {},
    //   savedDir: savedDir,
    //   saveInPublicStorage: true,
    // );
    // if (taskId != null) {
    //   model.taskId = taskId;
    // }
  }

  Future<void> pauseDownload(TaskModel model) async {
    await FlutterDownloader.pause(taskId: model.taskId);
  }

  Future<void> resumeDownload(TaskModel model) async {
    final newTaskId = await FlutterDownloader.resume(taskId: model.taskId);
    if (newTaskId != null) {
      model.taskId = newTaskId;
    }
  }

  Future<void> retryDownload(TaskModel model) async {
    final newTaskId = await FlutterDownloader.retry(taskId: model.taskId);
    if (newTaskId != null) {
      model.taskId = newTaskId;
    }
  }

  void openDownloadedFile(TaskModel model, Function() failed) async {
    if (model.status != DownloadTaskStatus.complete) {
      failed();
      return;
    }
    final taskId = model.taskId;

    await Future.delayed(const Duration(seconds: 1));
    var success = await FlutterDownloader.open(taskId: taskId);
    if (!success) {
      failed();
    }
  }

  Future<bool> checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }
    if (Platform.isAndroid) {
      var pList = [Permission.storage];
      final model = await DeviceInfoPlugin().androidInfo;
      if (model.version.sdkInt >= 30) {
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
      await DownloadService().prepareSaveDir();
    }
    return hasGranted;
  }
}
