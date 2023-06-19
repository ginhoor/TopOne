import 'package:flutter_tool_kit/interface/app_module_interface.dart';
import 'package:flutter_tool_kit/manager/file_manager.dart';
import 'package:top_one/service/download_service.dart';

enum SandboxDirType { document, temp }

enum ResourcePath {
  projectPath("Project", SandboxDirType.document),
  projectCache("ProjectCache", SandboxDirType.temp),
  zipCache("ZipCache", SandboxDirType.temp),
  downloadsCache("DownloadsCache", SandboxDirType.temp),
  shareCache("ShareCache", SandboxDirType.temp);

  const ResourcePath(this.path, this.parentDirType);

  /// 文件夹名称
  final String path;
  final SandboxDirType parentDirType;
}

class ResourceModule implements AppModuleInterface {
  static final ResourceModule instance = ResourceModule._instance();
  factory ResourceModule() => instance;
  ResourceModule._instance();

  bool hasGranted = false;
  @override
  int modulePriority = 4800;

  @override
  Future<void> loadModule() async {
    await DownloadService.instance.setupDirs();
  }

  @override
  Future<void> unloadModule() async {}

  Future<void> prepareDirs() async {
    // final hasGranted = await FileManager.checkPermission();
    // if (!hasGranted) return;
    // 初始化
    for (var path in ResourcePath.values) {
      dirPath(path);
    }
  }

  static Future<String?> dirPath(ResourcePath path) async {
    String parentDirPath = "";
    switch (path.parentDirType) {
      case SandboxDirType.document:
        parentDirPath = await FileManager.getDocumentsDirPath();
        break;
      case SandboxDirType.temp:
        parentDirPath = await FileManager.getTmpDirPath();
        break;
    }
    if (parentDirPath.isEmpty) return null;
    return await createDirIfNotExist(parentDirPath, path.path);
  }

  static Future<void> cleanProjectCache() async {
    var path = await dirPath(ResourcePath.projectCache);
    if (path == null) return;
    await FileManager.delete(path);
  }

  static Future<String> createDirIfNotExist(String parentDirPath, String dirPath) async {
    var path = FileManager.joinPath(parentDirPath, dirPath);
    await FileManager.createDirIfNotExist(path);
    return path;
  }
}
