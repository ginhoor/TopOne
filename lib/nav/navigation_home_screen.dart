import 'package:flutter/material.dart';
import 'package:top_one/module/index/index_screen.dart';
import 'package:top_one/theme/app_theme.dart';

class NavigationHomeScreen extends StatefulWidget {
  const NavigationHomeScreen({super.key});
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  @override
  void initState() {
    // screenView = const DownloadScreen();
    screenView = const IndexScreen();
    // const url =
    //     "https://v77.tiktokcdn.com/63efe1be2d7e67976b79ff1614216cf5/63c7bf5e/video/tos/useast2a/tos-useast2a-pve-0068/owNCRksJjQJ8ETBUQBgeJeBDo1nSY3AVQQbrF6/?a=1180&ch=0&cr=3&dr=0&lr=all&cd=0%7C0%7C0%7C3&cv=1&br=1784&bt=892&cs=0&ds=6&ft=K53eaPPT2K5jHBWH6BRfu.GDUjM5SuzBvU.7TGbR&mime_type=video_mp4&qs=0&rc=O2c4OTk4OGQ1PDQ6aGc4M0BpMzlkOmQ6Zm43aDMzNzczM0AvX2JeXjU0NjIxL14yYC5jYSNvaV8zcjQwLS5gLS1kMTZzcw%3D%3D&l=2023011803435067C90596CA2BEC8642D1&btag=80000&cc=13";
    // screenView = const VideoPreviewScreen(sourceURL: url);

    // screenView = DownloadScreen(
    //   title: "标题",
    //   platform: TargetPlatform.iOS,
    // );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: screenView,
        ),
      ),
    );
  }
}
