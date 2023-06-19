import 'package:flutter_tool_kit/interface/app_module_interface.dart';
import 'package:top_one/data/global_config_datasource.dart';
import 'package:top_one/data/tt_result_datasource.dart';

class DatasourceModule implements AppModuleInterface {
  static final DatasourceModule instance = DatasourceModule._instance();
  factory DatasourceModule() => instance;
  DatasourceModule._instance();

  bool hasGranted = false;
  @override
  int modulePriority = 4800;

  @override
  Future<void> loadModule() async {
    await TTResultDatasource.setup();
    await GlobalConfigDatasource.setup();
  }

  @override
  Future<void> unloadModule() async {}
}
