import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:top_one/theme/app_theme.dart';

class AppTitleLogo extends StatelessWidget {
  const AppTitleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        // Videos Downloader for TickTok
        Text(
          "Videos",
          style: TextStyle(
              color: AppTheme.nearlyBlack,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.5),
        ),
        Text(
          "Downloader",
          style: TextStyle(
              color: AppTheme.nearlyBlack,
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.5),
        ),
        Text(
          "for TickTok",
          style: TextStyle(
              color: AppTheme.nearlyBlack,
              fontSize: 25,
              fontWeight: FontWeight.w600,
              height: 1.5),
        )
      ],
    );
  }
}