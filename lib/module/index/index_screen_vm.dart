import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/tool/logger.dart';

const _isolatePortServerName = "index_downloader_send_port";

class IndexScreenVM extends ChangeNotifier {
  double topBarOpacity = 0.0;
  List<DownloadTask> downloaderTasks = [];
  List<TaskModel> items = [];
  Map<String, TaskModel> itemInfosMap = {};

  late State state;

  final _port = ReceivePort();

  loadTasks() async {
    downloaderTasks = await FlutterDownloader.loadTasks() ?? [];

//     items.clear();
//     itemInfosMap.clear();
// // TODO: 处理其他数据
//     var infos = downloaderTasks.map((task) {
//       var info =
//           TaskModel(name: "test", link: task.url, taskId: task.taskId);
//       return info;
//     });
//     items.addAll(infos.map((info) {
//       return TaskModel(name: info.taskId, info: info);
//     }));
//     for (var item in items) {
//       itemInfosMap[item.info.taskId] = item.info;
//     }
    notifyListeners();
  }

  createDownloadTask(String taskId, TTResult result) {
    final model = TaskModel(
      taskId: taskId,
      video: result.video,
      bgm: result.bgm,
      title: result.title,
      img: result.img,
      name: result.name,
      avatar: result.avatar,
    );

    items.insert(0, model);
    itemInfosMap[model.taskId] = model;
    notifyListeners();
  }

  updateDownloadInfo(String taskId, DownloadTaskStatus status, int progress) {
    var item = items.firstWhereOrNull((item) => item.taskId == taskId);
    if (item != null) {
      item
        ..status = status
        ..progress = progress;
      itemInfosMap.remove(item.taskId);
      itemInfosMap[item.taskId] = item;
      notifyListeners();
    }
  }

  updateTopBarOpacity(double topBarOpacity) {
    this.topBarOpacity = topBarOpacity;
    notifyListeners();
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
