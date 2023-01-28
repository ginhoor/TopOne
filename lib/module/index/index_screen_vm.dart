import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/tool/logger.dart';

const _isolatePortServerName = "index_downloader_send_port";

class IndexScreenVM extends ChangeNotifier {
  double topBarOpacity = 0.0;
  List<DownloadTask> downloaderTasks = [];
  List<TaskModel> items = [];

  late State state;

  final _port = ReceivePort();

  loadTasks() async {
    downloaderTasks = await FlutterDownloader.loadTasks() ?? [];
    items.clear();
    items.addAll(downloaderTasks.map((task) {
      var id = task.taskId;
      var info = DownloadInfo(name: id, link: task.url)..taskId = id;
      return TaskModel(name: id, info: info);
    }));
  }

  updateDownloadInfo(String taskId, DownloadTaskStatus status, int progress) {
    if (items.isEmpty) {
      return;
    }
    items.firstWhere((item) => item.info.taskId == taskId).info
      ..status = status
      ..progress = progress;
    state.setState(() {});
  }

  loadTestData() {
    var infos = DownloadItems.documents.map(
      (document) => DownloadInfo(name: document.name, link: document.url),
    );
    items.addAll(infos.map(
      (info) => TaskModel(name: info.name, info: info),
    ));
  }

  registerDownloaderCallback() {
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
  }

  @pragma('vm:entry-point')
  static downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    logDebug(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    IsolateNameServer.lookupPortByName(_isolatePortServerName)
        ?.send([id, status, progress]);
  }

  bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      _isolatePortServerName,
    );
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = data[1] as DownloadTaskStatus;
      final progress = data[2] as int;

      logDebug(
        'Callback on UI isolate: '
        'task ($taskId) is in status ($status) and process ($progress)',
      );

      updateDownloadInfo(taskId, status, progress);
    });
  }

  unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(_isolatePortServerName);
  }
}
