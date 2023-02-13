import 'dart:convert';

import 'package:gh_tool_package/http/http_resp.dart';
import 'package:top_one/api/http_engine.dart';

class HttpApi {
  static final HttpApi _httpService = HttpApi._instance();
  factory HttpApi() => _httpService;
  HttpApi._instance();

  Future<HttpResp> getTTResult(String url) async {
    var exist = HttpEngine().respCache[url];
    if (exist != null) {
      return exist;
    }
    try {
      var path = "/GetV3";
      Map<String, dynamic> params = {"link": url};
      var sign = HttpEngine().getAPISign(path, params);
      params = {
        "sign": sign.signString,
        "params": sign.paramsJson,
        "timestamp": sign.timestamp
      };
      var paramsJSON = json.encode(params);
      return await HttpEngine().post(path, data: paramsJSON);
    } catch (e) {
      return HttpResp.unknowError();
    }
  }
}
