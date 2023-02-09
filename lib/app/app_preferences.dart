import 'package:shared_preferences/shared_preferences.dart';

class AppPreferenceKey {
  /// int
  // ignore: constant_identifier_names
  static const String latest_download_complete_rate_date =
      'latest_download_complete_rate_date';

  /// int
  // ignore: constant_identifier_names
  static const String latest_play_complete_rate_date =
      'latest_play_complete_rate_date';

  /// int
  // ignore: constant_identifier_names
  static const String latest_agree_privacy_date = 'latest_agree_privacy_date';
}

class AppPreference {
  AppPreference._internal();
  static final AppPreference _instance = AppPreference._internal();
  factory AppPreference() => _instance;

  SharedPreferences? _sharedPreferences;

  Future setup() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void setBool(String key, bool value) {
    _sharedPreferences?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _sharedPreferences?.getBool(key);
  }

  void setString(String key, String value) {
    _sharedPreferences?.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPreferences?.getString(key);
  }

  void setInt(String key, int value) {
    _sharedPreferences?.setInt(key, value);
  }

  int? getInt(String key) {
    return _sharedPreferences?.getInt(key);
  }

  void setDouble(String key, double value) {
    _sharedPreferences?.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _sharedPreferences?.getDouble(key);
  }
}
