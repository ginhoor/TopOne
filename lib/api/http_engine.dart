import 'package:top_one/tool/http/base_http.dart';

var debugMode = true;

class HttpEngine extends BaseHttp {
  static const String BASE_URL_PROD = 'https://';
  static const String BASE_URL_DEV = 'http://127.0.0.1:8080';

  HttpEngine._internal() {
    String url = debugMode ? BASE_URL_DEV : BASE_URL_PROD;
    init(baseURL: url);
  }

  static final HttpEngine _instance = HttpEngine._internal();

  factory HttpEngine() => _instance;
}
