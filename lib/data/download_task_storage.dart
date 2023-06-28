import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_tool_kit/log/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DownloadTaskStorage implements PersistentStorage {
  sql.Database? db;

  final taskRecordsTable = 'taskRecords';
  final modifiedTasksTable = 'modifiedTasksTable';
  final pausedTasksTable = 'pausedTasksTable';
  final resumeDataTable = 'resumeDataTable';

  final taskIdColumn = 'taskId';
  final objectColumn = 'objectJsonMap';

  @override
  (String, int) get currentDatabaseVersion => ('Sqlite', 1);

  @override
  Future<void> initialize() async {
    final databasesPath =
        await (Platform.isIOS || Platform.isMacOS ? getLibraryDirectory() : getApplicationSupportDirectory());
    final path = join(databasesPath.path, 'download_task_records.sqlite');

    db = await sql.openDatabase(path, version: 1, onCreate: (sql.Database dbase, int version) async {
      // When creating the db, create the table
      // Note: database migration not implemented in this example, but should be
      // done if migrating from Localstore version, and for future updates
      await dbase.execute('CREATE TABLE $taskRecordsTable ($taskIdColumn TEXT PRIMARY KEY, $objectColumn TEXT)');
      await dbase.execute('CREATE TABLE $pausedTasksTable ($taskIdColumn TEXT PRIMARY KEY, $objectColumn TEXT)');
      await dbase.execute('CREATE TABLE $modifiedTasksTable ($taskIdColumn TEXT PRIMARY KEY, $objectColumn TEXT)');
      await dbase.execute('CREATE TABLE $resumeDataTable ($taskIdColumn TEXT PRIMARY KEY, $objectColumn TEXT)');
    });
  }

  Future<void> remove(String table, String? taskId) async {
    if (taskId == null) {
      await db?.delete(table, where: null);
    } else {
      await db?.delete(table, where: '$taskIdColumn = ?', whereArgs: [taskId]);
    }
  }

  @override
  Future<void> removeModifiedTask(String? taskId) => remove(modifiedTasksTable, taskId);

  @override
  Future<void> removePausedTask(String? taskId) => remove(pausedTasksTable, taskId);

  @override
  Future<void> removeResumeData(String? taskId) => remove(resumeDataTable, taskId);

  @override
  Future<void> removeTaskRecord(String? taskId) => remove(taskRecordsTable, taskId);

  @override
  Future<List<Task>> retrieveAllModifiedTasks() async {
    final result = await db?.query(modifiedTasksTable, columns: [objectColumn], where: null);
    if (result == null) return [];
    return result.map((e) => Task.createFromJsonMap(jsonDecode(e[objectColumn] as String))).toList(growable: false);
  }

  @override
  Future<List<Task>> retrieveAllPausedTasks() async {
    final result = await db?.query(pausedTasksTable, columns: [objectColumn], where: null);
    if (result == null) return [];
    return result.map((e) => Task.createFromJsonMap(jsonDecode(e[objectColumn] as String))).toList(growable: false);
  }

  @override
  Future<List<ResumeData>> retrieveAllResumeData() async {
    final result = await db?.query(resumeDataTable, columns: [objectColumn], where: null);
    if (result == null) return [];
    return result.map((e) => ResumeData.fromJsonMap(jsonDecode(e[objectColumn] as String))).toList(growable: false);
  }

  @override
  Future<List<TaskRecord>> retrieveAllTaskRecords() async {
    final result = await db?.query(taskRecordsTable, columns: [objectColumn], where: null);
    if (result == null) return [];
    return result.map((e) => TaskRecord.fromJsonMap(jsonDecode(e[objectColumn] as String))).toList(growable: false);
  }

  @override
  Future<Task?> retrieveModifiedTask(String taskId) async {
    final result =
        await db?.query(modifiedTasksTable, columns: [objectColumn], where: '$taskIdColumn = ?', whereArgs: [taskId]);
    if (result == null) return null;
    if (result.isEmpty) return null;
    return Task.createFromJsonMap(jsonDecode(result.first[objectColumn] as String));
  }

  @override
  Future<Task?> retrievePausedTask(String taskId) async {
    final result =
        await db?.query(pausedTasksTable, columns: [objectColumn], where: '$taskIdColumn = ?', whereArgs: [taskId]);
    if (result == null) return null;
    if (result.isEmpty) return null;
    return Task.createFromJsonMap(jsonDecode(result.first[objectColumn] as String));
  }

  @override
  Future<ResumeData?> retrieveResumeData(String taskId) async {
    final result =
        await db?.query(resumeDataTable, columns: [objectColumn], where: '$taskIdColumn = ?', whereArgs: [taskId]);
    if (result == null) return null;
    if (result.isEmpty) return null;
    return ResumeData.fromJsonMap(jsonDecode(result.first[objectColumn] as String));
  }

  @override
  Future<TaskRecord?> retrieveTaskRecord(String taskId) async {
    final result =
        await db?.query(taskRecordsTable, columns: [objectColumn], where: '$taskIdColumn = ?', whereArgs: [taskId]);
    if (result == null) return null;
    if (result.isEmpty) return null;
    return TaskRecord.fromJsonMap(jsonDecode(result.first[objectColumn] as String));
  }

  Future<void> store(String table, String taskId, Map<String, dynamic> jsonMap) async {
    final existingRecord =
        await db?.query(table, columns: [objectColumn], where: '$taskIdColumn = ?', whereArgs: [taskId]);
    logDebug("[task] [db] store ${table} taskId: ${taskId} exist: ${existingRecord}");
    if (existingRecord != null && existingRecord.isEmpty) {
      try {
        var row = await db?.insert(table, {taskIdColumn: taskId, objectColumn: jsonEncode(jsonMap)});
        logDebug("[task] [db] insert ${table} taskId: ${taskId} row: ${row}");
      } catch (e) {
        var row = await db?.update(taskRecordsTable, {objectColumn: jsonEncode(jsonMap)},
            where: '$taskIdColumn = ?', whereArgs: [taskId]);
        logDebug("[task] [db] retry update ${table} taskId: ${taskId} row: ${row}");
      }
    } else {
      var row = await db?.update(taskRecordsTable, {objectColumn: jsonEncode(jsonMap)},
          where: '$taskIdColumn = ?', whereArgs: [taskId]);
      logDebug("[task] [db] insert ${table} taskId: ${taskId} row: ${row}");
    }
  }

  @override
  Future<void> storeModifiedTask(Task task) => store(modifiedTasksTable, task.taskId, task.toJsonMap());

  @override
  Future<void> storePausedTask(Task task) => store(pausedTasksTable, task.taskId, task.toJsonMap());

  @override
  Future<void> storeResumeData(ResumeData resumeData) =>
      store(resumeDataTable, resumeData.taskId, resumeData.toJsonMap());

  @override
  Future<void> storeTaskRecord(TaskRecord record) {
    return store(taskRecordsTable, record.taskId, record.toJsonMap());
  }

  @override
  Future<(String, int)> get storedDatabaseVersion async {
    return ('Sqlite', await db?.getVersion() ?? 1);
  }
}