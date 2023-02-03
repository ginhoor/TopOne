class HttpResp {
  int code;
  String message;
  dynamic data;

  HttpResp({required this.code, this.message = "", this.data});

  factory HttpResp.fromMap(Map<String, dynamic> srcJson, {String? result}) {
    return HttpResp(
      code: srcJson['Code'] ?? srcJson['code'] ?? 99999,
      message:
          srcJson['Message'] ?? srcJson['msg'] ?? result ?? '网络或服务器异常，请稍后重试!',
      data: srcJson['data'],
    );
  }
}
