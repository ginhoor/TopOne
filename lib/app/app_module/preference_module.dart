import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:flutter_tool_kit/interface/app_module_interface.dart';

class PreferenceModule implements AppModuleInterface {
  static final PreferenceModule instance = PreferenceModule._instance();
  factory PreferenceModule() => instance;
  PreferenceModule._instance();

  bool hasGranted = false;
  @override
  int modulePriority = 4800;

  @override
  Future<void> loadModule() async {
    await AppPreference.instance.setup();
  }

  @override
  Future<void> unloadModule() async {}
}
