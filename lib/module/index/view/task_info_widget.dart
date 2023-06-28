import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/gen/colors.gen.dart';
import 'package:top_one/gen/locale_keys.gen.dart';
import 'package:top_one/manager/download_task_manager.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/module/index/download_task_vm.dart';
import 'package:top_one/module/video/video_preview_page+route.dart';
import 'package:top_one/service/analytics/analytics_event.dart';
import 'package:top_one/service/analytics/analytics_service.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/theme/theme_config.dart';
import 'package:top_one/view/dialog.dart';
import 'package:top_one/view/toast.dart';

Future<void> _onTap(BuildContext context, TaskModel model, WidgetRef ref, bool mounted,
    ChangeNotifierProvider<DownloadTaskVM> downloadTaskProvider) async {
  AnalyticsService().logEvent(AnalyticsEvent.previewVideo);
  var vm = ref.read(downloadTaskProvider);
  var tasks = vm.items;
  if (tasks.isEmpty) return;
  var task = vm.findTask(model.taskId);
  if (task == null) return;
  if (task.status != TaskStatus.complete) return;
  var record = await DownloadTaskManager.instance.getRecord(task.taskId);
  if (record == null) return;
  var filePath = await record.task.filePath();
  var fileExist = await File(filePath).exists();
  if (!fileExist && mounted) {
    ToastManager.instance.showTextToast(context, LocaleKeys.file_not_exist_error.tr());
    return;
  }
  var metaData = task.metaData;
  AppNavigator.pushRoute(VideoPreviewPageRouteHandler.instance.page(metaData, filePath));
}

Future<void> _onActionTap(BuildContext context, TaskModel model, WidgetRef ref, bool mounted,
    ChangeNotifierProvider<DownloadTaskVM> downloadTaskProvider) async {
  var vm = ref.read(downloadTaskProvider);
  var tasks = vm.items;
  if (tasks.isEmpty) return;
  var task = vm.findTask(model.taskId);
  if (task == null) return;
  if (task.status == TaskStatus.running) {
    await vm.pauseDownloadTask(task.taskId);
  } else if (task.status == TaskStatus.paused) {
    await vm.resumeDownloadTask(task.taskId);
  } else if (task.status == TaskStatus.complete || task.status == TaskStatus.canceled) {
    await vm.deleteDownloadTask(task.taskId);
  } else if (task.status == TaskStatus.failed) {
    await vm.retryDownloadTask(task.taskId);
  }
  return;
}

Future<void> _onDelete(BuildContext context, TaskModel model, WidgetRef ref, bool mounted,
    ChangeNotifierProvider<DownloadTaskVM> downloadTaskProvider) async {
  DialogManager.instance.showTextDialog(
    context,
    title: LocaleKeys.delete_task_title.tr(),
    message: model.metaData.title ?? "",
    actions: [
      TextButton(
        child: Text(LocaleKeys.delete.tr()),
        onPressed: () async {
          var vm = ref.read(downloadTaskProvider);
          await vm.deleteDownloadTask(model.taskId);
          AppNavigator.popPage();
        },
      ),
    ],
  );
}

Widget buildTaskItem(BuildContext context, TaskModel model, WidgetRef ref, bool mounted,
    ChangeNotifierProvider<DownloadTaskVM> downloadTaskProvider) {
  return TaskInfoWidget(
    data: model,
    onTap: (_) => _onTap(context, model, ref, mounted, downloadTaskProvider),
    onActionTap: (_) => _onActionTap(context, model, ref, mounted, downloadTaskProvider),
    onDelete: (_) => _onDelete(context, model, ref, mounted, downloadTaskProvider),
  );
}

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
        if (data.status != TaskStatus.complete) return;
        if (onTap != null) onTap!(data);
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
      borderRadius: BorderRadius.all(Radius.circular(dRadius / 2)),
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
        width: 50,
        height: 50,
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
      ms_toMMddHHmmss(data.startTime),
      textAlign: TextAlign.left,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 0.0, color: ColorName.deactivatedText),
    );
  }

  Widget get _progressIndicator {
    if (data.status == TaskStatus.running || data.status == TaskStatus.paused) {
      return LinearProgressIndicator(value: data.progress / 100);
    }
    return Container(height: 4);
  }

  Widget get _taskAction {
    if (data.status == TaskStatus.running) return pauseAction;
    if (data.status == TaskStatus.paused) return resumeAndDeleteAction;
    if (data.status == TaskStatus.complete) return deleteAction;
    if (data.status == TaskStatus.canceled) return canceledAction;
    if (data.status == TaskStatus.failed) return retryAction;
    if (data.status == TaskStatus.enqueued) return pendingAction;
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
        Text(LocaleKeys.done.tr(), style: TextStyle(color: ColorName.mainThemeAction)),
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
            alignment: Alignment.center,
            onPressed: () => onActionTap!(data),
            constraints: actionIconSize,
            icon: Icon(Icons.cancel, size: 24),
            tooltip: LocaleKeys.cancel.tr(),
          )
      ],
    );
  }

  Widget get resumeAndDeleteAction {
    return Row(
      children: [
        Text('${data.progress}%'),
        SizedBox(
          width: dPadding_2,
        ),
        if (onDelete != null)
          IconButton(
            onPressed: () => onDelete!(data),
            constraints: actionIconSize,
            icon: Icon(Icons.delete),
            tooltip: LocaleKeys.delete.tr(),
          ),
        if (onActionTap != null)
          IconButton(
            constraints: actionIconSize,
            icon: Icon(Icons.play_arrow, color: ColorName.mainThemeAction),
            onPressed: () => onActionTap!(data),
          ),
      ],
    );
  }

  Widget get pauseAction {
    return Row(
      children: [
        Text('${data.progress}%'),
        SizedBox(
          width: dPadding_2,
        ),
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
