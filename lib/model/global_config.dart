import 'package:hive_flutter/hive_flutter.dart';

part 'global_config.g.dart';

@HiveType(typeId: 1)
class GlobalConfig extends HiveObject {
  @HiveField(0)
  int? version;
  @HiveField(1)
  String? adVer;

  GlobalConfig fromJson(Map<String, dynamic> json) {
    version = json['version'] ?? 0;
    adVer = json['ad_ver'] ?? "";
    return this;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    data['ad_ver'] = adVer;
    return data;
  }
}
