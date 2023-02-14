import 'dart:convert';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:top_one/model/tt_result.dart';

class TaskModel {
  TaskModel(
      {required this.metaData,
      required this.taskId,
      this.progress = 0,
      this.status = DownloadTaskStatus.undefined});
  TTResult metaData;
  int startTime = DateTime.now().millisecondsSinceEpoch;
  String taskId;
  int progress;
  DownloadTaskStatus status;
}

class TaskInfo {
  String? taskId;
  // 1: video 2: bgm
  int type = 1;
  TTResult? metaData;
  TaskInfo.fromJson(Map<String, dynamic> data) {
    taskId = data['task_id'];
    type = data['type'];
    if (data['metaData'] != null) {
      metaData = TTResult().fromJson(json.decode(data['metaData']));
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['task_id'] = taskId;
    data['type'] = type;
    if (data['metaData'] != null) {
      data['metaData'] = json.encode(metaData);
    }
    return data;
  }
}
