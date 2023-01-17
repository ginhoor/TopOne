import 'package:flutter/material.dart';
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
            child: addShadows(generateActionButton("Paste", () {})),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: SizedBox(
            height: 50,
            child: addShadows(generateActionButton("Download", () {})),
          ),
        )
      ],
    );
  }

  Widget generateTextFiled() {
    return addShadows(
      TextField(
        // maxLength: maxLength,
        // autofocus: true,
        // inputFormatters: [
        //   LengthLimitingTextInputFormatter(maxLength)
        // ],
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
