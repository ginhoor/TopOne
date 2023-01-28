import 'package:flutter_downloader/flutter_downloader.dart';

class TaskModel {
  TaskModel(
      {this.bgm,
      this.title,
      this.img,
      this.avatar,
      this.name,
      this.video,
      required this.taskId});

  final String? name;
  final String? video;
  final String? bgm;
  final String? title;
  final String? img;
  final String? avatar;
  final int startTime = DateTime.now().millisecondsSinceEpoch;
  String taskId;

  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;
}
