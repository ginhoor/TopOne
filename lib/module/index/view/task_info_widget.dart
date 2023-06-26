import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/manager/time.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';

class TaskInfoWidget extends StatelessWidget {
  TaskInfoWidget({
    Key? key,
    required this.data,
    this.onTap,
    this.onActionTap,
    this.onDelete,
  }) : super(key: key);

  final TaskModel data;

  final Function(TaskModel)? onTap;
  final Function(TaskModel)? onActionTap;
  final Function(TaskModel)? onDelete;

  final BoxConstraints actionIconSize = BoxConstraints(minHeight: 32, minWidth: 32);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data.status != DownloadTaskStatus.complete) return;
        if (onTap == null) return;
        onTap!(data);
      },
      child: _buildBorder(child: _content),
    );
  }

  Widget _buildBorder({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.all(Radius.circular(dRadius)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: AppTheme.grey.withOpacity(0.2), offset: const Offset(1.1, 1.1), blurRadius: 10.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(left: dPadding, right: dPadding, top: dPadding, bottom: dPadding_2),
        child: child,
      ),
    );
  }

  Widget get _content {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _image,
            Expanded(child: _title),
          ],
        ),
        SizedBox(height: dPadding_2),
        Row(
          children: [
            _timeIcon,
            SizedBox(width: dPadding_2),
            Expanded(child: _time),
            _taskAction,
          ],
        ),
        _progressIndicator
      ],
    );
  }

  Widget get _image {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(dRadius)),
      child: CachedNetworkImage(
        imageUrl: data.metaData.img ?? "",
        placeholder: (context, url) => Padding(
          padding: EdgeInsets.all(dPadding_2),
          child: CircularProgressIndicator(
            backgroundColor: ColorName.background,
            valueColor: AlwaysStoppedAnimation(ColorName.mainThemeAction),
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget get _title {
    return Padding(
      padding: EdgeInsets.all(dPadding_2),
      child: Text(
        data.metaData.title ?? "",
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        maxLines: 3,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.0,
          color: AppTheme.darkText,
        ),
      ),
    );
  }

  Widget get _timeIcon {
    return Icon(Icons.access_time, color: ColorName.deactivatedText, size: 14);
  }

  Widget get _time {
    return Text(
      timeFormatMDHMS(data.startTime),
      textAlign: TextAlign.left,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.0, color: ColorName.deactivatedText),
    );
  }

  Widget get _progressIndicator {
    if (data.status == DownloadTaskStatus.running || data.status == DownloadTaskStatus.paused) {
      return LinearProgressIndicator(value: data.progress / 100);
    }
    return Container();
  }

  Widget get _taskAction {
    if (data.status == DownloadTaskStatus.running) return pauseAction;
    if (data.status == DownloadTaskStatus.paused) return resumeAndCancelAction;
    if (data.status == DownloadTaskStatus.complete) return deleteAction;
    if (data.status == DownloadTaskStatus.canceled) return canceledAction;
    if (data.status == DownloadTaskStatus.failed) return retryAction;
    if (data.status == DownloadTaskStatus.enqueued) return pendingAction;
    return startAction;
  }

  Widget get startAction {
    return IconButton(
      onPressed: () => onActionTap?.call(data),
      constraints: actionIconSize,
      icon: Icon(Icons.file_download),
      tooltip: LocaleKeys.start.tr(),
    );
  }

  Widget get pendingAction {
    return Text(LocaleKeys.pending.tr(), style: TextStyle(color: Colors.orange));
  }

  Widget get retryAction {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(LocaleKeys.failed.tr(), style: TextStyle(color: ColorName.redAction)),
        if (onActionTap != null)
          IconButton(
            onPressed: () => onActionTap!(data),
            icon: Icon(Icons.refresh, color: ColorName.mainThemeAction),
            tooltip: LocaleKeys.retry.tr(),
          )
      ],
    );
  }

  Widget get deleteAction {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(LocaleKeys.done.tr(), style: TextStyle(color: ColorName.mainThemeAction)).tr(),
        if (onActionTap != null)
          IconButton(
            onPressed: () => onActionTap!(data),
            constraints: actionIconSize,
            icon: Icon(Icons.delete),
            tooltip: LocaleKeys.delete.tr(),
          )
      ],
    );
  }

  Widget get canceledAction {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(LocaleKeys.cancel.tr(), style: TextStyle(color: ColorName.redAction)),
        if (onActionTap != null)
          IconButton(
            onPressed: () => onActionTap!(data),
            constraints: actionIconSize,
            icon: const Icon(Icons.cancel),
            tooltip: LocaleKeys.cancel.tr(),
          )
      ],
    );
  }

  Widget get resumeAndCancelAction {
    return Row(
      children: [
        Text('${data.progress}%'),
        if (onActionTap != null)
          IconButton(
            onPressed: () => onActionTap!(data),
            constraints: actionIconSize,
            icon: Icon(Icons.play_arrow, color: ColorName.mainThemeAction),
            tooltip: LocaleKeys.resume.tr(),
          ),
        if (onDelete != null)
          IconButton(
            onPressed: () => onDelete!(data),
            constraints: actionIconSize,
            icon: Icon(Icons.delete),
            tooltip: LocaleKeys.delete.tr(),
          ),
      ],
    );
  }

  Widget get pauseAction {
    return Row(
      children: [
        Text('${data.progress}%'),
        if (onActionTap != null)
          IconButton(
            onPressed: () => onActionTap!(data),
            constraints: actionIconSize,
            icon: Icon(Icons.pause, color: Colors.yellow),
            tooltip: LocaleKeys.pause.tr(),
          )
      ],
    );
  }
}
