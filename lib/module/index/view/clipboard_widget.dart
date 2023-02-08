import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/view/utils.dart';

class ClipboardWidget extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  final Future<bool> Function(String text)? handleDownload;

  const ClipboardWidget(
      {Key? key,
      required this.animationController,
      required this.animation,
      this.handleDownload})
      : super(key: key);

  @override
  State<ClipboardWidget> createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget>
    with WidgetsBindingObserver {
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 自动读取剪贴板
      handlePasteAction();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget? child) {
        return addFadeTransition(
            Column(
              children: <Widget>[
                generateTextFiled(),
                const SizedBox(height: 8),
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
            height: 40,
            child: addShadows(
              generateActionButton("paste", handlePasteAction,
                  FitnessAppTheme.nearlyWhite, FitnessAppTheme.grey),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 40,
            child: addShadows(
              generateActionButton("download", () async {
                if (widget.handleDownload != null) {
                  var success =
                      await widget.handleDownload!(_inputController.text);
                  if (success) {
                    setState(() {
                      _inputController.text = "";
                    });
                  }
                }
              }, FitnessAppTheme.actionGreen, FitnessAppTheme.nearlyWhite),
            ),
          ),
        )
      ],
    );
  }

  Widget generateTextFiled() {
    return addShadows(
      TextField(
        maxLines: 1, //最多多少行
        minLines: 1,
        controller: _inputController,
        // focusNode: _inputFocusNode,
        cursorColor: FitnessAppTheme.nearlyBlack,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Type In Link To Start...',
          suffixIcon: IconButton(
            onPressed: _inputController.clear,
            icon: const Icon(Icons.clear),
          ),
          fillColor: Colors.grey[50],
          filled: true,
          isCollapsed: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
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
