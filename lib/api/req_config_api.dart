import 'package:gh_tool_package/http/http_resp.dart';
import 'package:gh_tool_package/log/logger.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/api/req_ttd_api.dart';
import 'package:top_one/model/global_config.dart';

extension Config on HttpApi {
  Future<GlobalConfig> getGlobalConfig() async {
    try {
      var path = "https://gfrtopone.github.io/global_config/v1/data.json";
      HttpResp resp = await HttpEngine().get(path);
      if (resp.data == null) throw Error();
      var result = GlobalConfig().fromJson(resp.data);
      if (result.version == null) throw Error();
      return result;
    } catch (e) {
      throw HttpResp.unknowError();
    }
  }
}
