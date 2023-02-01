import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/model/downloads.dart';
import 'package:top_one/module/index/index_screen_vm.dart';
import 'package:top_one/module/index/view/task_info_widget.dart';
import 'package:top_one/module/video/video_preview_screen.dart';
import 'package:top_one/service/analytics_event.dart';
import 'package:top_one/service/analytics_service.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/view/app_top_bar.dart';
import 'package:top_one/view/toast.dart';

import 'view/clipboard_widget.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen>
    with TickerProviderStateMixin {
  var vm = IndexScreenVM();
  late Animation<double> topBarAnimation;
  List<Widget> staticCells = [];
  // 进入页面后的动效时长
  late AnimationController animationController;
  final scrollController = ScrollController();

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    scrollController.addListener(_handleTopBarWhenScroll);
    setupDownloader();
    setupStaticCells();
    vm.loadTasks();
    super.initState();
  }

  setupDownloader() {
    vm.bindBackgroundIsolate();
    vm.registerDownloaderCallback();
  }

  setupStaticCells() {
    int count = 9;
    staticCells.add(
      ClipboardWidget(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        animationController: animationController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: ChangeNotifierProvider.value(
        value: vm,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              _buildListView(),
              _buildAppTopBar(),
              SizedBox(height: MediaQuery.of(context).padding.bottom)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppTopBar() {
    return Selector(
      builder: (context, topBarOpacity, _) {
        return AppTopBar(animationController, topBarAnimation, topBarOpacity);
      },
      selector: (BuildContext context, IndexScreenVM vm) {
        return vm.topBarOpacity;
      },
    );
  }

  Widget _buildListView() {
    return Selector(
      builder: (BuildContext context, String version, _) {
        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top +
                24,
            bottom: 62 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: staticCells.length + vm.items.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            animationController.forward();
            if (index < staticCells.length) {
              return staticCells[index];
            }
            var item = vm.items[index - staticCells.length];
            return buildTaskItem(context, item);
          },
        );
      },
      selector: (BuildContext context, IndexScreenVM vm) {
        return vm.itemsVersion;
      },
    );
  }

  Widget buildTaskItem(BuildContext context, TaskModel model) {
    return TaskInfoWidget(
      data: model,
      onTap: (model) async {
        AnalyticsService().logEvent(AnalyticsEvent.previewVideo);
        var exist = await vm.findCompletedTask(model.taskId);
        if (exist == null) {
          if (!mounted) return;
          showToast(context, const Text('open_file_error').tr());
          return;
        }
        var item = vm.getItem(model.taskId);
        if (item == null) return;
        var metaData = item.metaData;
        var filePath = path.join(exist.savedDir, exist.filename);
        AppNavigator.pushPage(VideoPreviewScreen(
          metaData: metaData,
          localFilePath: filePath,
        ));
      },
      onActionTap: (model) async {
        if (model.status == DownloadTaskStatus.undefined) {
        } else if (model.status == DownloadTaskStatus.running) {
          await vm.pauseDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.paused) {
          await vm.resumeDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.complete ||
            model.status == DownloadTaskStatus.canceled) {
          await vm.deleteDownloadTask(model.taskId);
        } else if (model.status == DownloadTaskStatus.failed) {
          await vm.retryDownloadTask(model.taskId);
        }
      },
      onCancel: (model) {
        vm.deleteDownloadTask(model.taskId);
      },
    );
  }

  void _handleTopBarWhenScroll() {
    if (scrollController.offset >= 24) {
      if (vm.topBarOpacity != 1.0) vm.updateTopBarOpacity(1.0);
    } else if (scrollController.offset <= 24 && scrollController.offset >= 0) {
      var val = scrollController.offset / 24;
      if (vm.topBarOpacity != val) vm.updateTopBarOpacity(val);
    } else if (scrollController.offset <= 0) {
      if (vm.topBarOpacity != 0.0) vm.updateTopBarOpacity(0.0);
    }
  }
}
