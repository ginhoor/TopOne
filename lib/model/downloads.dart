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
