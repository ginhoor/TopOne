import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:top_one/api/http_engine.dart';
import 'package:top_one/tool/http/http_resp.dart';
import 'package:top_one/tool/logger.dart';

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
      String? token;
      token = "";
      return await HttpEngine()
          .get("/GetResult", queryParameters: {"link": url});

      token = await FirebaseAppCheck.instance.getToken();
      logDebug("FirebaseAppCheck token -> $token");
      if (token == null || token == "") return HttpResp.fromMap({});
      Map<String, dynamic>? headerData = {"X-Firebase-Appcheck": token};

      return await HttpEngine().get("/GetV2",
          headerData: headerData, queryParameters: {"link": url});
    } catch (e) {
      return HttpResp.unknowError();
    }
  }
}
