import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:top_one/api/req_ttd_api.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/module/index/index_screen_vm.dart';
import 'package:top_one/service/analytics_event.dart';
import 'package:top_one/service/analytics_service.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/view/toast.dart';
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
    AnalyticsService().logEvent(AnalyticsEvent.pasteUrl);
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
    AnalyticsService().logEvent(AnalyticsEvent.tapDownload);
    var url = _inputController.text;
    if (!verifyURL(url)) {
      if (mounted) {
        showToast(context, const Text("url_invaild_error").tr());
      }
      return;
    }
    await EasyLoading.show(status: "chacking".tr());
    var resp = await HttpApi().getTTResult(url);
    var result = TTResult.fromJson(resp.data);
    // logDebug(result.name);
    // logDebug(result.title);
    // logDebug(result.video);
    // logDebug(result.bgm);
    // logDebug(result.avatar);
    // logDebug(result.img);
    if (result.video == null) return;
    var vm = Provider.of<IndexScreenVM>(context, listen: false);
    var success = await vm.createDownloadTask(result);
    await EasyLoading.dismiss();
    if (!success && mounted) {
      showToast(context, const Text("create_task_failed_error").tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
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
              generateActionButton("paste", handlePasteAction),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 50,
            child: addShadows(
              generateActionButton("download", handleDownloadAction),
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
