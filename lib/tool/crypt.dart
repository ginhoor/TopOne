//aes加密
import 'package:encrypt/encrypt.dart';

final key = Key.fromUtf8("Gw11FzWc3A80vPs7");

final iv = IV.fromUtf8("Giaj5NxUFjb3Eki8");

Encrypted aesEncode(String content, Key key, IV iv) {
  // final key = Key.fromUtf8("8888888888888888");
  // final iv = IV.fromUtf8("8888888888888888")
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(content, iv: iv);
  return encrypted;
}

//aes解密
dynamic aesDecode(dynamic base64, Key key, IV iv) {
  try {
    // final key = Key.fromUtf8("8888888888888888");
    // final iv = IV.fromUtf8("8888888888888888")
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt64(base64, iv: iv);
  } catch (err) {
    print("aes decode error:$err");
    return base64;
  }
}
