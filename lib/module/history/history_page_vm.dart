import 'package:flutter/widgets.dart';

class HistoryPageVM extends ChangeNotifier {
  bool inlineadLoaded = false;
  void setInlineadLoaded() {
    if (inlineadLoaded) return;
    inlineadLoaded = true;
    notifyListeners();
  }
}
