import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:top_one/app/logger.dart';
import 'package:top_one/service/app_info_service.dart';

import 'http_resp.dart';

class BaseHttp {
  late Dio _dio;

  Dio get dio => _dio;

  late String _baseURL;

  void init({
    required baseURL,
  }) {
    _baseURL = baseURL;

    var options = BaseOptions(
      baseUrl: _baseURL,
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
      connectTimeout: 10000,
      receiveTimeout: 10000,
    );
    _dio = Dio(options);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
        // var appVersion = Utils().appVersion;
        // options.headers['user-agent'] = 'daqun/$appVersion';
        return handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        return handler.next(response);
      },
    ));
  }

  // void addHttpProxy() {
  //   if (Utils().proxySetting == null) {
  //     return;
  //   }

  //   if (!Utils().proxySetting.enabled) {
  //     return;
  //   }

  //   (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
  //       (client) {
  //     client.badCertificateCallback = (cert, host, port) => Platform.isAndroid;
  //     client.findProxy = (uri) {
  //       return 'PROXY ${Utils().proxySetting.host}:${Utils().proxySetting.port}';
  //     };
  //     // 代理工具会提供一个抓包的自签名证书，会通不过证书校验，所以我们禁用证书校验
  //     if (Utils().forTest) {
  //       client.badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true;
  //     }
  //     return client;
  //   };
  // }

  static Map<String, dynamic> getDefaultHeader() {
    return {
      'os': AppInfoService().sysInfo.os,
      'version': AppInfoService().appVersion,
    };
  }

  Options getOptions(String method,
      {Options? options, Map<String, dynamic>? headerData}) {
    Map<String, dynamic> headers = getDefaultHeader();
    if (headerData != null && headerData.isNotEmpty) {
      headers.addAll(headerData);
    }
    if (options == null) {
      options = Options(method: method, headers: headers);
    } else {
      options = options.copyWith(method: method);
      if (options.headers != null) {
        options.headers!.addAll(headers);
      } else {
        options.headers = headers;
      }
    }

    return options;
  }

  // String getSignature(int timestamp, String paramsStr, {String ticket = ''}) {
  //   String input;
  //   if (ticket != '') {
  //     input = '$_bfPid$_bfMCPKey$timestamp$ticket$paramsStr';
  //   } else {
  //     input = '$_bfPid$_bfMCPKey$timestamp$paramsStr';
  //   }
  //   return md5.convert(utf8.encode(input)).toString();
  // }

  Future<Map<String, dynamic>> getParamsData(dynamic paramsValue) async {
    // var timestamp = Utils.currentNetworkTimestamp();
    // String paramsJson;
    // if (paramsValue == null) {
    //   paramsJson = '{}';
    // } else {
    //   paramsJson = jsonEncode(paramsValue);
    // }

    // ticket ??= await AuthManager().fetchTicket();

    Map<String, dynamic> data = {
      // 'paramsValue': paramsJson,
      // 'timestamp': timestamp,
      // 'pid': bfPid,
      // '_signature': getSignature(timestamp, paramsJson, ticket: ticket),
    };
    // if (ticket != '') {
    //   data['ticket'] = ticket;
    // }
    return paramsValue;
  }

  HttpResp handleResponse(Response? response, String path, bool showErr) {
    if (response != null) {
      Map<String, dynamic> respData;

      if (response.data is Map) {
        respData = response.data;
      } else if (response.data is String) {
        try {
          respData = jsonDecode(response.data);
        } catch (e) {
          logError('[BastHttp]handleResponse jsonDecode: $e');
          return HttpResp(code: 88888, message: '数据格式错误');
        }
      } else {
        return HttpResp(code: 88888, message: '数据格式错误');
      }
      var resp = HttpResp.fromMap(respData, result: response.toString());

      if (resp.code != 0) {
        handlError(path, resp, showErr);
      }
      return resp;
    } else {
      return HttpResp.requestError();
    }
  }

  void handlError(String path, HttpResp resp, bool showErr) {
    if (resp.code != 0) {
      logError('[BaseHttp]path: $path, code: ${resp.code}');
      // if (showErr && !AuditHelper().isAuditMode) {
      //   HttpError.showHttpError(path, resp);
      // }

      // if (resp.code == 4012) {
      //   AuthManager().notifRefreshTicket();
      // } else if (resp.code == 5002) {
      //   logError('[BaseHttp]handlError5002: $path, kickoff');
      //   AuthManager().logout(true);
      // }
    }
  }

  Future<HttpResp> request(
    String path,
    String method, {
    data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headerData,
    CancelToken? cancelToken,
    Options? options,
    bool showErr = true,
    bool retry = true,
  }) async {
    options = getOptions(method, options: options, headerData: headerData);
    try {
      var response = await _dio.request(
        path,
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: options,
      );
      return handleResponse(response, path, showErr);
    } catch (e) {
      return HttpResp.requestError();
    }

    // try {
    //   final RetryOptions retryOptions =
    //       RetryOptions(maxAttempts: retry ? 3 : 1);
    //   return await retryOptions.retry(
    //     () async {

    //     },
    //     retryIf: (e) =>
    //         e is SocketException || e is TimeoutException || e is DioError,
    //     onRetry: (e) {
    //       logScreen('[BaseHttp]$method path: $path, retry: $e');
    //     },
    //   );
    // } catch (e) {
    //   logScreen('[BaseHttp]$method path: $path, err: $e');
    //   return HttpResp(code: 99999);
    // }
  }

  Future<HttpResp> get(
    String path, {
    Map<String, dynamic>? headerData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool showErr = true,
    bool retry = false,
  }) async {
    queryParameters = queryParameters ?? <String, dynamic>{};
    Map<String, dynamic> params = await getParamsData(queryParameters);
    return request(
      path,
      'GET',
      headerData: headerData,
      queryParameters: params,
      cancelToken: cancelToken,
      options: options,
      showErr: showErr,
      retry: retry,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    bool showErr = true,
    bool retry = true,
  }) async {
    // Map<String, dynamic> data = await getParamsData(paramsValue);
    // data['pKey'] = bfMCPKey;
    // data['method'] = 'POST';

    return request(
      path,
      'POST',
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      showErr: showErr,
      retry: retry,
    );
  }

  Future<HttpResp> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool showErr = true,
    bool retry = true,
  }) async {
    Map<String, dynamic> data = await getParamsData(queryParameters);

    return request(
      path,
      'DELETE',
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      showErr: showErr,
      retry: retry,
    );
  }

  Future<HttpResp> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool showErr = true,
    bool retry = true,
  }) async {
    Map<String, dynamic> data = await getParamsData(queryParameters);

    return request(
      path,
      'PUT',
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      showErr: showErr,
      retry: retry,
    );
  }
}
