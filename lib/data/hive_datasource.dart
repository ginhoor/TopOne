import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:top_one/data/global_config_datasource.dart';
import 'package:top_one/data/tt_result_datasource.dart';
import 'package:top_one/model/global_config.dart';
import 'package:top_one/model/tt_result.dart';

class HiveDatasource {
  HiveDatasource._internal();
  factory HiveDatasource() => _instance;
  static final HiveDatasource _instance = HiveDatasource._internal();

  static String databaseName = "HDB";
  BoxCollection? collection;

  static Set<String> boxNames() {
    return {
      TTResultDatasource.boxName,
      GlobalConfigDatasource.boxName,
    };
  }

  static ensureInitialized() async {
    final directory = await getApplicationDocumentsDirectory();
    var hiveDirPath = path.join(directory.path, 'Data');
    Hive.initFlutter(hiveDirPath);
    Hive.registerAdapter(TTResultAdapter());
    Hive.registerAdapter(GlobalConfigAdapter());
    // Create a box collection
    final collection = await BoxCollection.open(
      HiveDatasource.databaseName, // Name of your database
      HiveDatasource.boxNames(), // Names of your boxes
      path:
          hiveDirPath, // Path where to store your boxes (Only used in Flutter / Dart IO)
      // key: HiveCipher(), // Key to encrypt your boxes (Only used in Flutter / Dart IO)
    );
    HiveDatasource().collection = collection;
  }
}
