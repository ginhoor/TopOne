import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/utils.dart';

class ClipboardWidget extends StatefulWidget {
  final Future<bool> Function(String text)? handleDownload;
  const ClipboardWidget({Key? key, this.handleDownload}) : super(key: key);
  @override
  State<ClipboardWidget> createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget> with WidgetsBindingObserver {
  final TextEditingController _inputController = TextEditingController();
  final OutlineInputBorder _outlineInputBorder = outlineInputBorder;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 注册监听器
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除监听器
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 自动读取剪贴板，自动开始下载
      var result = await getClipboardData();
      if (result == null) return;
      var url = result.text!;
      if (!TTResult.verifyURL(url)) return;
      clearClipboard();
      if (widget.handleDownload == null) return;
      widget.handleDownload!(url);
    }
  }

  clearClipboard() {
    Clipboard.setData(const ClipboardData(text: ""));
  }

//读取剪切板 返回
  Future<ClipboardData?> getClipboardData() async {
    return await Clipboard.getData(Clipboard.kTextPlain);
  }

  Future<void> handlePasteAction() async {
    AnalyticsService().logEvent(AnalyticsEvent.pasteUrl);
    var result = await getClipboardData();
    if (result != null) {
      var text = result.text!;
      setState(() {
        _inputController.text = text;
      });
    }
  }

  Future<void> handleDownloadAction() async {
    if (widget.handleDownload != null) {
      var success = await widget.handleDownload!(_inputController.text);
      if (success) {
        setState(() {
          _inputController.text = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _textFiled,
        SizedBox(height: dPadding),
        _actionBar,
      ],
    );
  }

  Widget get _actionBar {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: dBtnSize,
            child: addShadows(
              generateActionButton("paste", AppTheme.nearlyWhite, AppTheme.grey, handlePasteAction),
            ),
          ),
        ),
        SizedBox(width: dPadding),
        Expanded(
          child: SizedBox(
            height: dBtnSize,
            child: addShadows(
              generateActionButton("download", AppTheme.actionGreen, AppTheme.nearlyWhite, handleDownloadAction),
            ),
          ),
        )
      ],
    );
  }

  Widget get _textFiled {
    return addShadows(
      TextField(
        maxLines: 1, //最多多少行
        minLines: 1,
        controller: _inputController,
        // focusNode: _inputFocusNode,
        cursorColor: AppTheme.nearlyBlack,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Type In Link To Start...',
          suffixIcon: InkWell(
              borderRadius: BorderRadius.circular(30), // 设置一个圆角边框，用于限制点击效果的范围
              onTap: _inputController.clear,
              child: Icon(Icons.clear)),
          fillColor: Colors.grey[50],
          filled: true,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
