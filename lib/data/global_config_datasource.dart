import 'package:hive/hive.dart';
import 'package:top_one/data/hive_datasource.dart';
import 'package:top_one/model/global_config.dart';

class GlobalConfigDatasource {
  static String boxName = "GlobalConfigDatasource";
  CollectionBox<GlobalConfig>? box;
  BoxCollection? col;
  GlobalConfigDatasource._internal();

  static final GlobalConfigDatasource instance = GlobalConfigDatasource._internal();
  factory GlobalConfigDatasource() => instance;

  static Future<bool> setup() async {
    var col = HiveDatasource().collection;
    if (col == null) return false;
    instance.col = col;
    // Open your boxes. Optional: Give it a type.
    final box = await col.openBox<GlobalConfig>(GlobalConfigDatasource.boxName);
    instance.box = box;
    return true;
  }

  transaction(Future<void> Function() action, {bool readOnly = false}) async {
    col?.transaction(action,
        boxNames: [boxName], // By default all boxes become blocked.
        readOnly: readOnly);
  }

  save(GlobalConfig result) async {
    var exist = await get();
    if (result.version == null || exist.version == null) return;
    if (result.version! <= exist.version!) return;
    await box?.put("default", result);
  }

  Future<GlobalConfig> get() async {
    var exist = await box?.get("default");
    var defaultConfig = GlobalConfig().fromJson({"version": 0, "ad_ver": "0.0.0"});
    return exist ?? defaultConfig;
  }

  delete() async {
    await box?.delete("default");
  }

  clear() async {
    await box?.clear();
  }
}
