import 'package:top_one/api/http_engine.dart';
import 'package:top_one/tool/http/http_resp.dart';

class HttpApi {
  static final HttpApi _httpService = HttpApi._instance();

  factory HttpApi() => _httpService;

  HttpApi._instance();

  Future<HttpResp> getTTResult(String url) async {
    return await HttpEngine().get("/GetResult", queryParameters: {"link": url});
  }
}
