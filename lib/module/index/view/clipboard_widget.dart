import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/model/tt_result.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/button.dart';
import 'package:top_one/theme/theme_config.dart';

class ClipboardWidget extends StatefulWidget {
  final Future<bool> Function(String text)? handleDownload;
  const ClipboardWidget({Key? key, this.handleDownload}) : super(key: key);
  @override
  State<ClipboardWidget> createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget> with WidgetsBindingObserver {
  final TextEditingController _inputController = TextEditingController();

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
    FocusScope.of(context).unfocus();
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
    FocusScope.of(context).unfocus();
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
        SizedBox(height: dPadding_2),
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
            child: normalBtn(LocaleKeys.paste.tr(), onTap: handlePasteAction),
          ),
        ),
        SizedBox(width: dPadding),
        Expanded(
          child: SizedBox(
            height: dBtnSize,
            child: actionBtn(LocaleKeys.download.tr(), onTap: handleDownloadAction),
          ),
        )
      ],
    );
  }

  Widget get _textFiled {
    return Container(
      height: 70,
      //阴影
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorName.grey.withOpacity(0.2),
            spreadRadius: 1, // 阴影的扩展半径
            blurRadius: dPadding_2, // 阴影的模糊半径
            offset: Offset(0, 0), // 阴影的偏移量
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: dBorderRadius,
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          maxLines: 1, //最多多少行
          minLines: 1,
          controller: _inputController,
          // focusNode: _inputFocusNode,
          cursorColor: ColorName.mainThemeAction,
          style: TextStyle(fontSize: 15, color: ColorName.blackText),
          decoration: InputDecoration(
              hintText: LocaleKeys.clipboard_hint_title.tr(),
              suffixIcon: InkWell(
                  borderRadius: BorderRadius.circular(70 / 2), // 设置一个圆角边框，用于限制点击效果的范围
                  onTap: _inputController.clear,
                  child: Icon(Icons.clear, color: ColorName.blackText)),
              fillColor: Colors.white,
              filled: true,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(horizontal: dPadding, vertical: dPadding),
              prefixIcon: SizedBox(height: 70, child: Icon(Icons.link, color: ColorName.blackText)),
              border: InputBorder.none),
        ),
      ),
    );
  }
}
