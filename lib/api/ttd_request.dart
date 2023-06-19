import 'dart:async';
import 'dart:convert';

import 'package:flutter_tool_kit/error/axv_error.dart';
import 'package:flutter_tool_kit/http/base_http.dart';
import 'package:flutter_tool_kit/http/base_http_reqeust.dart';
import 'package:flutter_tool_kit/http/http_result.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/model/tt_result.dart';

class TDDResultRequest implements BaseHttpRequest {
  @override
  String path = "/GetV3";

  Future<TTResult?> requestResult(String url) async {
    try {
      var result = await request(HttpEngine(), {"link": url});
      if (result.error != null) return null;

      var responseData = result.resp?.data;
      Map<String, dynamic>? respData;
      if (responseData is String) {
        dynamic jsonData = jsonDecode(responseData);
        respData = jsonData;
      }
      if (respData == null) return null;
      var data = respData["data"];
      if (data == null) return null;
      var ttResult = TTResult().fromJson(data);
      if (ttResult.video == null) return null;
      return ttResult;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<HttpResult> request(BaseHttp engine, Map<String, dynamic> params) async {
    var sign = HttpEngine().getAPISign(path, params);
    params = {"sign": sign.signString, "params": sign.paramsJson, "timestamp": sign.timestamp};
    var paramsJSON = json.encode(params);
    var httpEngine = engine as HttpEngine?;
    if (httpEngine == null) throw AXVError.paramsInvalid;
    HttpResult result = await engine.post(path, data: paramsJSON);
    return result;
  }
}
