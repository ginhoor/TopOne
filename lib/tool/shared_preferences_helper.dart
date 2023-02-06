import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceKeys {
  static const String latest_rate_date = 'latest_rate_date';
}

class SharedPreferencesHelper {
  static late SharedPreferencesHelper _instance;

  SharedPreferencesHelper._internal() {
    _instance = this;
    init();
  }

  factory SharedPreferencesHelper() =>
      _instance ?? SharedPreferencesHelper._internal();

  late SharedPreferences _sharedPreferences;

  Future init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void setBool(String key, bool value) {
    _sharedPreferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  void setString(String key, String value) {
    _sharedPreferences.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  void setInt(String key, int value) {
    _sharedPreferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  void setDouble(String key, double value) {
    _sharedPreferences.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _sharedPreferences.getDouble(key);
  }
}
