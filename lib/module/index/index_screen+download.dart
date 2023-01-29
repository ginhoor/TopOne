import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:top_one/module/index/index_screen.dart';
import 'package:top_one/service/download_service.dart';

extension HandleDownload on IndexScreen {
  Widget buildNoPermissionWarning() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Text(
              'storage_permission_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey, fontSize: 18),
            ).tr(),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () async {
              final hasGranted = await DownloadService().checkPermission();
              if (hasGranted) await DownloadService().setupDirs();
            },
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
