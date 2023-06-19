import 'package:flutter_tool_kit/interface/app_module_interface.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:top_one/api/global_config_request.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/app/app_module/app_info_module.dart';
import 'package:top_one/data/global_config_datasource.dart';
import 'package:top_one/service/ad/ad_service.dart';

class NetworkModule implements AppModuleInterface {
  static final NetworkModule instance = NetworkModule._instance();
  factory NetworkModule() => instance;
  NetworkModule._instance();

  bool hasGranted = false;
  @override
  int modulePriority = 4800;

  @override
  Future<void> loadModule() async {
    await HttpEngine.setup();
    await loadAdService();
  }

  @override
  Future<void> unloadModule() async {}

  Future<void> loadAdService() async {
    if (ADService.instance.forceEnable) {
      ADService.instance.enable = true;
      ADService.instance.preloadAds();
      return;
    }
    GlobalConfigRequest().requestConfiguration().then((value) async {
      if (value == null) return;
      await GlobalConfigDatasource.instance.save(value);
      var config = await GlobalConfigDatasource().get();
      var adEnable = config.adVer != null && AppInfoModule.instance.appVersion.compareTo(config.adVer!) < 0;
      logDebug("global remote: ${value.adVer} local adVer: ${config.adVer} adEnable: $adEnable");
      if (adEnable) {
        ADService.instance.enable = true;
        ADService.instance.preloadAds();
      }
    });
  }
}
