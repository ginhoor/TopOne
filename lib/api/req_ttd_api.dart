import 'dart:convert';

import 'package:gh_tool_package/http/http_resp.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/model/tt_result.dart';

class HttpApi {
  static final HttpApi _httpService = HttpApi._instance();
  factory HttpApi() => _httpService;
  HttpApi._instance();

  Future<TTResult> getTTResult(String url) async {
    // var exist = HttpEngine().respCache.getValue(url);
    // if (exist != null) {
    //   return TTResult().fromJson(Map<String, dynamic>.from(exist));
    // }
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
      HttpResp resp = await HttpEngine().post(path, data: paramsJSON);
      if (resp.data == null) throw Error();
      var result = TTResult().fromJson(resp.data);
      if (result.video == null) throw Error();
      // HttpEngine().respCache.setValue(url, resp.data);
      return result;
    } catch (e) {
      throw HttpResp.unknowError();
    }
  }
}
