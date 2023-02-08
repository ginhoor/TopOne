import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:top_one/service/app_info_service.dart';
import 'package:top_one/tool/http/base_http.dart';
import 'package:top_one/tool/http/http_resp.dart';
import 'package:top_one/tool/time.dart';

// var debugMode = true;
var debugMode = false;
const String key =
    "lNbp9up4rZuK0fbbic09jCHOX1OWuqfSWNy4qqbHLhWs3NZ2SSVu6KC5hiSKMLtB";

class APISign {
  final int timestamp;
  final String os;
  final String path;
  final String version;
  final String paramsJson;
  final String signString;
  APISign(this.timestamp, this.version, this.os, this.path, this.paramsJson,
      this.signString);
}

class HttpEngine extends BaseHttp {
  static const String BASE_URL_PROD =
      'https://us-central1-topone-376314.cloudfunctions.net';
  static const String BASE_URL_DEV = 'http://127.0.0.1:8080';

  HttpEngine._internal() {
    String url = debugMode ? BASE_URL_DEV : BASE_URL_PROD;
    init(baseURL: url);
  }

  static final HttpEngine _instance = HttpEngine._internal();

  factory HttpEngine() => _instance;

  HashMap<String, HttpResp> respCache = HashMap<String, HttpResp>();

  APISign getAPISign(String path, Map<String, dynamic> params) {
    final timestamp = currentTimestamp();
    final version = AppInfoService().appVersion;
    final os = AppInfoService().sysInfo.os;

    String paramsJson = json.encode(params);

    String content = "$timestamp" +
        key.substring(0, 16) +
        version +
        key.substring(16, 24) +
        os +
        key.substring(24, 32) +
        path +
        key.substring(32, 48) +
        paramsJson +
        key.substring(48, 64);

    String signString = md5.convert(utf8.encode(content)).toString();
    return APISign(timestamp, version, os, path, paramsJson, signString);
  }
}
