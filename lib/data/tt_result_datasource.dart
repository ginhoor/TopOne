import 'package:hive/hive.dart';
import 'package:top_one/data/hive_datasource.dart';
import 'package:top_one/model/tt_result.dart';

class TTResultDatasource {
  static String boxName = "TTResultDatasource";
  CollectionBox<TTResult>? box;
  BoxCollection? col;
  TTResultDatasource._internal();

  static final TTResultDatasource _instance = TTResultDatasource._internal();
  factory TTResultDatasource() => _instance;

  static Future<bool> setup() async {
    var col = HiveDatasource().collection;
    if (col == null) return false;
    _instance.col = col;
    // Open your boxes. Optional: Give it a type.
    final box = await col.openBox<TTResult>(TTResultDatasource.boxName);
    _instance.box = box;
    return true;
  }

  transaction(Future<void> Function() action, {bool readOnly = false}) async {
    col?.transaction(action,
        boxNames: [boxName], // By default all boxes become blocked.
        readOnly: readOnly);
  }

  save(String taskId, TTResult result) async {
    await box?.put(taskId, result);
  }

  Future<TTResult?> query(String taskId) async {
    return await box?.get(taskId);
  }

  Future<List<TTResult?>?> queryAll(List<String> taskIds) async {
    return await box?.getAll(taskIds);
  }

  Future<List<String>?> allKeys() async {
    return await box?.getAllKeys();
  }

  Future<Map<String, TTResult>?> allValues() async {
    return await box?.getAllValues();
  }

  delete(String taskId) async {
    await box?.delete(taskId);
  }

  deleteAll(List<String> taskIds) async {
    await box?.deleteAll(taskIds);
  }

  clear(List<String> taskIds) async {
    await box?.clear();
  }
}
