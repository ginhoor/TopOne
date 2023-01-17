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
    // screenView = const MyHomePage();
    screenView = const IndexScreen();
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
