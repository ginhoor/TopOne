import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/theme/app_theme.dart';
import 'package:top_one/tool/time.dart';

class TaskInfoWidget extends StatelessWidget {
  const TaskInfoWidget({
    Key? key,
    required this.data,
    this.onTap,
    this.onActionTap,
    this.onCancel,
  }) : super(key: key);

  final TaskModel data;

  final Function(TaskModel)? onTap;
  final Function(TaskModel)? onActionTap;
  final Function(TaskModel)? onCancel;

  @override
  Widget build(BuildContext context) {
    return _buildTap(
      context,
      _buildBorder(
        context,
        _buildContent(
          context,
        ),
      ),
    );
  }

  Widget _buildTap(BuildContext context, Widget content) {
    return InkWell(
      onTap: data.status == DownloadTaskStatus.complete
          ? () {
              onTap != null ? onTap!(data) : null;
            }
          : null,
      child: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              child: CachedNetworkImage(
                imageUrl: data.metaData.img ?? "",
                placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      Colors.grey[800],
                    ),
                    strokeWidth: 10.0,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 5, right: 8, bottom: 14),
                child: Text(
                  data.metaData.title ?? "",
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.0,
                    color: AppTheme.darkText,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: AppTheme.grey.withOpacity(0.5),
                size: 14,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                  ),
                  child: Text(
                    timeFormatMDHMS(data.startTime),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: 0.0,
                      color: AppTheme.grey.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              _buildTrailing(data),
            ],
          ),
        ),
        if (data.status == DownloadTaskStatus.running ||
            data.status == DownloadTaskStatus.paused)
          LinearProgressIndicator(
            value: data.progress / 100,
          ),
      ],
    );
  }

  Widget _buildTrailing(TaskModel data) {
    if (data.status == DownloadTaskStatus.running) {
      return Row(
        children: [
          Text('${data.progress}%'),
          IconButton(
            onPressed: () => onActionTap?.call(data),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.pause, color: Colors.yellow),
            tooltip: 'pause'.tr(),
          ),
        ],
      );
    } else if (data.status == DownloadTaskStatus.paused) {
      return Row(
        children: [
          Text('${data.progress}%'),
          IconButton(
            onPressed: () => onActionTap?.call(data),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.play_arrow, color: Colors.green),
            tooltip: 'resume'.tr(),
          ),
          if (onCancel != null)
            IconButton(
              onPressed: () => onCancel?.call(data),
              constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: 'cancel'.tr(),
            ),
        ],
      );
    } else if (data.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('done', style: TextStyle(color: Colors.green)).tr(),
          IconButton(
            onPressed: () => onActionTap?.call(data),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.delete),
            tooltip: 'delete'.tr(),
          )
        ],
      );
    } else if (data.status == DownloadTaskStatus.canceled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('cancel', style: TextStyle(color: Colors.red)).tr(),
          if (onActionTap != null)
            IconButton(
              onPressed: () => onActionTap?.call(data),
              constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
              icon: const Icon(Icons.cancel),
              tooltip: 'cancel'.tr(),
            )
        ],
      );
    } else if (data.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('failed', style: TextStyle(color: Colors.red)).tr(),
          IconButton(
            onPressed: () => onActionTap?.call(data),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
            icon: const Icon(Icons.refresh, color: Colors.green),
            tooltip: 'retry'.tr(),
          )
        ],
      );
    } else if (data.status == DownloadTaskStatus.enqueued) {
      return const Text('pending', style: TextStyle(color: Colors.orange)).tr();
    } else {
// if (data.status == DownloadTaskStatus.undefined) {
      return IconButton(
        onPressed: () => onActionTap?.call(data),
        constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
        icon: const Icon(Icons.file_download),
        tooltip: 'start'.tr(),
      );
    }
  }

  Widget _buildBorder(BuildContext context, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(68.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppTheme.grey.withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: content,
        ),
      ),
    );
  }
}
