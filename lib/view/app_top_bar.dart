import 'package:flutter/material.dart';
import 'package:top_one/service/app_info_service.dart';
import 'package:top_one/theme/fitness_app_theme.dart';

class AppTopBar extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  final double topBarOpacity;

  final Function() tapSettings;
  final Function() tapDownloadList;

  const AppTopBar(this.animationController, this.animation, this.topBarOpacity,
      {required this.tapSettings, required this.tapDownloadList, super.key});
  @override
  Widget build(BuildContext context) {
    return generateAppTopBar(animationController, animation, topBarOpacity);
  }

  Widget generateAppTopBar(AnimationController animationController,
      Animation<double> topBarAnimation, double topBarOpacity) {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey
                              .withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  appName,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: FitnessAppTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                iconSize: 30,
                                icon: const Icon(Icons.settings),
                                color: FitnessAppTheme.nearlyBlack,
                                onPressed: tapSettings),
                            IconButton(
                                iconSize: 30,
                                color: FitnessAppTheme.nearlyBlack,
                                icon: const Icon(
                                    Icons.download_for_offline_rounded),
                                onPressed: tapDownloadList),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
