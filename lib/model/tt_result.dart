class TTResult {
  String? video;
  String? bgm;
  String? title;
  String? img;
  String? name;
  String? avatar;

  TTResult.fromJson(Map<String, dynamic> json) {
    video = json['video'] ?? "";
    bgm = json['bgm'] ?? "";
    title = json['title'] ?? "";
    img = json['img'] ?? "";
    name = json['name'] ?? "";
    avatar = json['avatar'] ?? "";
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
}
