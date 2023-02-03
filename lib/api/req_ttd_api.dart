import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/tool/http/http_resp.dart';

class HttpApi {
  static final HttpApi _httpService = HttpApi._instance();
  factory HttpApi() => _httpService;
  HttpApi._instance();

  Future<HttpResp> getTTResult(String url) async {
    var token;
    if (kDebugMode) {
      token = "";
      return await HttpEngine()
          .get("/GetResult", queryParameters: {"link": url});

      // return await HttpEngine()
      //     .get("/GetV2", headerData: headerData, queryParameters: {"link": url});
    } else {
      token = await FirebaseAppCheck.instance.getToken();
    }
    if (token == null || token == "") return HttpResp.fromMap({});
    Map<String, dynamic>? headerData = {"X-Firebase-Appcheck": token};

    // return await HttpEngine().get("/GetResult",
    //     headerData: headerData, queryParameters: {"link": url});

    return await HttpEngine()
        .get("/GetV2", headerData: headerData, queryParameters: {"link": url});
  }
}
