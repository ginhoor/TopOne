import 'package:flutter_tool_kit/error/axv_error.dart';
import 'package:flutter_tool_kit/http/base_http.dart';
import 'package:flutter_tool_kit/http/base_http_reqeust.dart';
import 'package:flutter_tool_kit/http/http_result.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/model/global_config.dart';

class GlobalConfigRequest implements BaseHttpRequest {
  @override
  String path = "https://gfrtopone.github.io/global_config/v1/data.json";

  Future<GlobalConfig?> requestConfiguration() async {
    try {
      var result = await request(HttpEngine(), {});
      if (result.error != null) return null;
      var respData = result.resp?.data as Map<String, dynamic>?;
      if (respData == null) return null;
      var data = respData["data"];
      if (data == null) return null;
      var config = GlobalConfig().fromJson(data);
      return config;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<HttpResult> request(BaseHttp engine, Map<String, dynamic> params) async {
    var httpEngine = engine as HttpEngine?;
    if (httpEngine == null) throw AXVError.paramsInvalid;
    HttpResult result = await engine.get(path);
    return result;
  }
}
