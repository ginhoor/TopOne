import 'package:dio/dio.dart';

class HttpError {
  static Map<int, String> errCode = {
    0: '请求成功',
    99999: '网络或服务器异常，请稍后重试!',
  };

  // static void showHttpError(String path, HttpResp resp) {
  //   if (resp.code == 0) {
  //     return;
  //   }

  //   var message = errCode[resp.code] ?? resp.message;
  //   if (Utils().networkStatus == NetworkStatus.cellular || Utils().networkStatus == NetworkStatus.wifi) {
  //     if (kDebugMode || Utils().forTest) {
  //       Utils.showToast(path + ':' + message);
  //     } else {
  //       Utils.showToast(message);
  //     }
  //   }
  //   logScreen('[HttpError]showHttpError: $path : $message');
  // }

  static void dioError(String path, DioError error, bool showErr) {
    var message = error.message;
    switch (error.type) {
      case DioErrorType.connectTimeout:
        message = '网络连接超时，请检查网络设置!';
        break;
      case DioErrorType.receiveTimeout:
        message = '服务器异常，请稍后重试!';
        break;
      case DioErrorType.sendTimeout:
        message = '网络请求超时，请检查网络设置!';
        break;
      case DioErrorType.response:
        message = '服务器异常，请稍后重试！';
        break;
      case DioErrorType.cancel:
        message = '请求已被取消，请重新请求!';
        break;
      case DioErrorType.other:
        message = '网络或服务器异常，请稍后重试!';
        break;
    }
    // if (showErr &&
    //     (Utils().networkStatus == NetworkStatus.cellular ||
    //         Utils().networkStatus == NetworkStatus.wifi)) {
    //   if (Utils().forTest) {
    //     Utils.showToast(path + ':' + message);
    //   } else {
    //     Utils.showToast(message);
    //   }
    // }

    // logScreen('[HttpError](dioError)showHttpError: $path : $message');
  }
}
