import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:top_one/api/req_ttd_api.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/module/index/index_screen_vm.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/tool/logger.dart';
import 'package:top_one/view/utils.dart';

class ClipboardWidget extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  const ClipboardWidget(
      {Key? key, required this.animationController, required this.animation})
      : super(key: key);

  @override
  State<ClipboardWidget> createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget> {
  final TextEditingController _inputController = TextEditingController();
  final OutlineInputBorder _outlineInputBorder = outlineInputBorder;

//复制
  copyText(text) {
    Clipboard.setData(ClipboardData(text: text));
  }

//读取剪切板 返回
  Future<ClipboardData?> getClipboardData() async {
    return await Clipboard.getData(Clipboard.kTextPlain);
  }

  handlePasteAction() async {
    var result = await getClipboardData();
    if (result != null) {
      var text = result.text!;
      setState(() {
        _inputController.text = text;
      });
    }
  }

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

  handleDownloadAction() async {
    var url = _inputController.text;
    url = "https://vt.tiktok.com/ZS8DV7GDd/";
    if (!verifyURL(url)) {
      logDebug("链接无效");
      return;
    }
    var resp = await HttpApi().getTTResult(url);
    var result = TTResult.fromJson(resp.data);
    logDebug(result.name);
    logDebug(result.title);
    logDebug(result.video);
    logDebug(result.bgm);
    logDebug(result.avatar);
    logDebug(result.img);

    if (result.video != null) {
      var taskId = await downloadFile(result.video!);
      if (taskId != null) {
        var vm = Provider.of<IndexScreenVM>(context, listen: false);
        vm.createDownloadTask(taskId, result);
      }
    }
  }

  Future<String> getDownloadDirPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    var savedDirPath = path.join(documentDirectory.path, 'Downloads');
    var dir = Directory(savedDirPath);
    try {
      bool exists = await dir.exists();
      if (!exists) {
        await dir.create();
      }
    } catch (e) {
      logError(e.toString());
    }
    return savedDirPath;
  }

  Future<String?> downloadFile(String url) async {
    var savedDir = await getDownloadDirPath();
    logDebug(savedDir);
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      headers: {}, // optional: header send with url (auth token etc)
      savedDir: savedDir,
      showNotification:
          true, // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
    return taskId;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return addFadeTransition(
            Column(
              children: <Widget>[
                generateTextFiled(),
                const SizedBox(height: 16),
                generateActionBar(),
              ],
            ),
            widget.animation);
      },
    );
  }

  Widget generateActionBar() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: addShadows(
              generateActionButton("Paste", handlePasteAction),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 50,
            child: addShadows(
              generateActionButton("Download", handleDownloadAction),
            ),
          ),
        )
      ],
    );
  }

  Widget generateTextFiled() {
    return addShadows(
      TextField(
        maxLines: 5, //最多多少行
        minLines: 3,
        controller: _inputController,
        // focusNode: _inputFocusNode,
        cursorColor: FitnessAppTheme.nearlyBlack,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Type In Link To Start...',
          fillColor: Colors.grey[50],
          filled: true,
          isCollapsed: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          border: _outlineInputBorder,
          focusedBorder: _outlineInputBorder,
          enabledBorder: _outlineInputBorder,
          disabledBorder: _outlineInputBorder,
          focusedErrorBorder: _outlineInputBorder,
          errorBorder: _outlineInputBorder,
        ),
      ),
    );
  }
}
