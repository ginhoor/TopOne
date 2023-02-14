import 'package:gh_tool_package/log/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  Box? _box;

  Future<void> init(String boxName) async {
    try {
      if (_box != null && _box!.isOpen) {
        await close();
        _box = null;
      }
      _box = await Hive.openBox(boxName);
      logDebug('[HiveStorage] $boxName path: ${_box?.path}');
    } catch (e) {
      logError('[HiveStorage] init $boxName: $e');
      Hive.deleteBoxFromDisk(boxName);
      _box = await Hive.openBox(boxName);
    }
  }

  Future<void> setValue<T>(dynamic key, T value) async {
    await _box?.put(key, value);
  }

  T getValue<T>(dynamic key, {T? defaultValue}) {
    return _box?.get(key, defaultValue: defaultValue);
  }

  Future<void> clear() async {
    await _box?.clear();
  }

  Future<void> clean() async {
    await _box?.deleteFromDisk();
  }

  Future<void> close() async {
    if (_box?.isOpen ?? false) {
      await _box?.close();
    }
  }
}
