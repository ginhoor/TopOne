import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_one/api/req_ttd_api.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/view/utils.dart';

class ClipboardWidget extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  const ClipboardWidget({Key? key, this.animationController, this.animation})
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

  handleDownloadAction() async {
    // getRequestFunction1();
    var resp = await HttpApi().getTTResult(_inputController.text);
    print(resp.code);
    print(resp.message);
    print(resp.data);
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
            widget.animation!);

        // FadeTransition(
        //   opacity: widget.animation!,
        //   child: Transform(
        //     transform: Matrix4.translationValues(
        //         0.0, 30 * (1.0 - widget.animation!.value), 0.0),
        //     child: Padding(
        //       padding: const EdgeInsets.only(
        //           left: 24, right: 24, top: 16, bottom: 18),
        //       child:,
        //     ),
        //   ),
        // );
      },
    );
  }

  Widget generateActionBar() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: addShadows(generateActionButton("Paste", handlePasteAction)),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 50,
            child: addShadows(
                generateActionButton("Download", handleDownloadAction)),
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
