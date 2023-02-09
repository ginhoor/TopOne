import 'dart:async';

import 'package:flutter/foundation.dart';

class AppVM extends ChangeNotifier {
  Future<void> init() async {
    // _packageInfo = await PackageInfo.fromPlatform();

    // _imStatus = IMEngine().imStatus.imStatus;
    // _unread = TopicManager().unread;
    // _showHomeCode = AppPreference().getBool(AppPreferenceKey.HOME_SHOW_CODE);
    // _imStatusSubscription = IMEngine().imStatus.imStatusStream.stream.listen(_onIMStatusChanged);
    // _unreadSubscription = TopicManager().unreadStream.stream.listen(_onUnreadChanged);

    // AuthManager().authStatusStream.stream.listen(_onAuthStatusChanged);
  }

  @override
  Future<void> dispose() async {
    // await _imStatusSubscription.cancel();
    // await _unreadSubscription.cancel();
    super.dispose();
  }
}
