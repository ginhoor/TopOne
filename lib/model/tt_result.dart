import 'package:hive_flutter/hive_flutter.dart';

part 'tt_result.g.dart';

@HiveType(typeId: 0)
class TTResult extends HiveObject {
  @HiveField(0)
  String? video;
  @HiveField(1)
  String? bgm;
  @HiveField(2)
  String? title;
  @HiveField(3)
  String? img;
  @HiveField(4)
  String? name;
  @HiveField(5)
  String? avatar;

  TTResult fromJson(Map<String, dynamic> json) {
    video = json['video'] ?? "";
    bgm = json['bgm'] ?? "";
    title = json['title'] ?? "";
    img = json['img'] ?? "";
    name = json['name'] ?? "";
    avatar = json['avatar'] ?? "";
    return this;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['video'] = video;
    data['bgm'] = bgm;
    data['title'] = title;
    data['img'] = img;
    data['name'] = name;
    data['avatar'] = avatar;
    return data;
  }

  static bool verifyURL(String url) {
    var rule1 = RegExp('^http(s|)://.*tiktok.com.*/.*\$');
    if (rule1.hasMatch(url)) {
      return true;
    }
    var rule2 = RegExp('(/analytics\b)|(/music\b)|(m.tiktok.com/v/)');
    if (rule2.hasMatch(url)) {
      return true;
    }
    return false;
  }
}
