import 'package:flutter/material.dart';

class UIConstant {
  static const double kHorizontalPadding = 15.0;
  static const double kAppBarHeight = 44.0;
  static const double kNormalAvatarSize = 48.0;
  static const double kNormalListTileHeight = 64.0;
  static const double kChatAvatarSize = 40.0;
  static const double kMoreInputHeight = 269.0;
  static const double kSessionInputHeight = 60.0;
  static const double redpacketItemHeight = 54.0;
  static const double collectUserAvatarSize = 48.0;
  static const EdgeInsets kCollectAvatarMargin =
      EdgeInsets.fromLTRB(3, 14, 11, 14);
  static const double kCollectContentHeight = 85.0;
  static const EdgeInsets kCollectContentMargin = EdgeInsets.all(4);
  static const EdgeInsets kCollcectSubContentColumnMarin =
      EdgeInsets.only(top: 12, bottom: 16);
  static const EdgeInsets kCollcectMsgCardSubContentColumnMarin =
      EdgeInsets.only(top: 4, bottom: 8);
  static const double kCollectColumnSubContentPadding = 6.0;
  static const double kCollectActionFeedCardTitleFontSize = 16.0;
  static const double kCollectActionFeedCardSubTitleFontSize = 15.0;

  static const double kReplyDetailUserAvatarSize = 31.0;
  static const EdgeInsets kReplyDetailAvatarMargin =
      EdgeInsets.fromLTRB(4, 7, 14.5, 0);
  static const double kReplyDetailContentHeight = 45.0;
  static const EdgeInsets kReplyDetailContentMargin = EdgeInsets.all(0);
  static const EdgeInsets kReplyDetailSubContentColumnMarin =
      EdgeInsets.only(top: 0, bottom: 0);
  static const double kReplyDetailColumnSubContentPadding = 3.0;
  static const double kReplyDetailActionFeedCardTitleFontSize = 16.0;
  static const double kReplyDetailActionFeedCardSubTitleFontSize = 11.0;

  static const Widget SizedBoxZero = SizedBox();

  static ScrollPhysics get scrollPhysics =>
      const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
}
