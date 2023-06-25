import 'package:flutter/material.dart';
import 'package:top_one/app/theme_config.dart';
import 'package:top_one/theme/app_theme.dart';

class AppTopBar extends StatelessWidget {
  final bool hasNewHistory;

  final Function() tapSettings;
  final Function() tapDownloadList;

  const AppTopBar({required this.tapSettings, required this.tapDownloadList, required this.hasNewHistory, super.key});
  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: statusBarHeight),
      child: ClipRRect(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(dRadius), bottomRight: Radius.circular(dRadius)),
        child: Container(
          color: Colors.white,
          height: 64,
          child: _topBar,
        ),
      ),
    );
  }

  Widget get _topBar {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _title,
          ),
        ),
        _settings,
        _history,
      ],
    );
  }

  Widget get _title {
    return Text(
      "Start",
      textAlign: TextAlign.left,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: 1.2,
        color: AppTheme.nearlyBlack,
      ),
    );
  }

  Widget get _settings {
    return IconButton(
        iconSize: 30, icon: const Icon(Icons.settings), color: AppTheme.nearlyBlack, onPressed: tapSettings);
  }

  Widget get _history {
    var iconBtn = IconButton(
      iconSize: 30,
      color: AppTheme.nearlyBlack,
      icon: const Icon(Icons.download_for_offline_rounded),
      onPressed: tapDownloadList,
    );

    if (hasNewHistory) {
      return Stack(
        children: [
          iconBtn,
          Positioned(
            top: 5,
            right: 2,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 10,
                minHeight: 10,
              ),
            ),
          ),
        ],
      );
    }
    return iconBtn;
  }
}
