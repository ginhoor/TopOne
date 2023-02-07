import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/download_service.dart';

extension Metadata on DownloadService {
  bool verifyURL(String url) {
    var rule1 = RegExp('^http(s|)://.*tiktok.com.*/.*\$');
    if (rule1.hasMatch(url)) {
      return true;
    }
    var rule2 = RegExp('(/analytics\b)|(/music\b)|(m.tiktok.com/v/)');
    if (rule2.hasMatch(url)) {
      return true;
    }
    return false;
  }

  Future<TTResult?> queryMetaData(String taskId) async {
    final dirPath = await DownloadService().getMetaDataDirPath();
    final filePath = path.join(dirPath, taskId);
    final file = File(filePath);
    var fileExists = file.existsSync();
    if (fileExists) {
      var fileContent = json.decode(file.readAsStringSync());
      return TTResult.fromJson(fileContent);
    }
    return null;
  }

  saveMetaData(String taskId, TTResult result) async {
    final dirPath = await DownloadService().getMetaDataDirPath();
    final filePath = path.join(dirPath, taskId);
    final file = File(filePath);
    file.createSync();
    var content = result.toJson();
    file.writeAsStringSync(json.encode(content));
  }

  deleteMetaData(String taskId) async {
    final dirPath = await DownloadService().getMetaDataDirPath();
    final filePath = path.join(dirPath, taskId);
    final file = File(filePath);
    file.delete();
  }
}
