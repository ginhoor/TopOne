// class TaskModel {
//   TaskModel(
//       {required this.metaData,
//       required this.taskId,
//       this.progress = 0,
//       this.status = DownloadTaskStatus.undefined});
//   TTResult metaData;
//   int startTime = DateTime.now().millisecondsSinceEpoch;
//   String taskId;
//   int progress;
//   DownloadTaskStatus status;
// }
// To parse this JSON data, do
//
//     final taskModel = taskModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:top_one/model/tt_result.dart';

class TaskModel {
  TTResult metaData;
  int startTime;
  String taskId;
  int progress;
  DownloadTaskStatus status;

  TaskModel({
    required this.metaData,
    required this.startTime,
    required this.taskId,
    this.progress = 0,
    this.status = DownloadTaskStatus.undefined,
  });

  TaskModel copyWith({
    TTResult? metaData,
    int? startTime,
    String? taskId,
    int? progress,
    DownloadTaskStatus? status,
  }) =>
      TaskModel(
        metaData: metaData ?? this.metaData,
        startTime: startTime ?? this.startTime,
        taskId: taskId ?? this.taskId,
        progress: progress ?? this.progress,
        status: status ?? this.status,
      );

  factory TaskModel.fromRawJson(String str) => TaskModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        metaData: json["metaData"],
        startTime: json["startTime"],
        taskId: json["taskId"],
        progress: json["progress"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "metaData": metaData,
        "startTime": startTime,
        "taskId": taskId,
        "progress": progress,
        "status": status,
      };
}
