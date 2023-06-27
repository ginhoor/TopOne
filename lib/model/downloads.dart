// class TaskModel {
//   TaskModel(
//       {required this.metaData,
//       required this.taskId,
//       this.progress = 0,
//       this.status = TaskStatus.undefined});
//   TTResult metaData;
//   int startTime = DateTime.now().millisecondsSinceEpoch;
//   String taskId;
//   int progress;
//   TaskStatus status;
// }
// To parse this JSON data, do
//
//     final taskModel = taskModelFromJson(jsonString);

import 'package:background_downloader/background_downloader.dart';
import 'package:top_one/model/tt_result.dart';

class TaskModel {
  TTResult metaData;
  int startTime;
  String taskId;
  int progress;
  String filePath;
  TaskStatus status;

  TaskModel({
    required this.metaData,
    required this.startTime,
    required this.taskId,
    required this.filePath,
    this.progress = 0,
    this.status = TaskStatus.enqueued,
  });
}
