import 'dart:developer';

import 'package:routinepal_api/src/routinepal_db_base.dart';
import 'package:sqflite/sqflite.dart';

import 'models/models.dart';

class RoutinepalSqliteDb implements RoutinepalDbBase {
  Database? _db;

  RoutinepalSqliteDb();

  @override
  Future<void> init() async {
    _db = await openDatabase('routine_data.db', version: 3,
        onCreate: (db, version) async {
      await db.execute("""
    CREATE TABLE task_groups (
      group_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT
    );
    """);

      await db.execute("""
    CREATE TABLE "tasks" (
      task_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      task_group_id INTEGER,
      CONSTRAINT task_definitions_FK FOREIGN KEY (task_group_id) REFERENCES task_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE
    );
    """);

      await db.execute("""
    CREATE TABLE routines (
      routine_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      task_group_id INTEGER NOT NULL,
      fulfillment_time TIME NOT NULL,
      title TEXT NOT NULL,
      CONSTRAINT routines_FK FOREIGN KEY (task_group_id) REFERENCES task_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE
    );
    """);

      await db.execute("""
    CREATE TABLE task_completions (
      completion_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      task_id INTEGER NOT NULL,
      completion_date DATE NOT NULL,
      completion_time TIME NOT NULL,
      CONSTRAINT task_completions_FK FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE ON UPDATE CASCADE
    );
    """);
    });
  }

  @override
  Future<Task?> getTask(int taskId) async {
    List<Map<String, dynamic>> results =
        await _db!.query('tasks', where: 'task_id = $taskId');

    if (results.isNotEmpty) {
      return Task(
        id: results[0]['task_id'],
        title: results[0]['title'],
        description: results[0]['description'],
      );
    }

    return null;
  }

  @override
  Future<List<Task>> getTasksPartOfGroup(int groupId) async {
    List<Map<String, dynamic>> results =
        await _db!.query('tasks', where: 'task_group_id = $groupId');

    return results.map((task) {
      return Task(
        id: task['task_id'],
        title: task['title'],
        description: task['description'],
      );
    }).toList();
  }

  @override
  Future<List<Routine>> getFulfillableRoutines() async {
    List<Map<String, dynamic>> results = await _db!.query('routines');

    List<Routine> routines = [];

    //TODO implement this
    for (var routineData in results) {
      log("fulfillment time: ${routineData['fulfillment_time']}");
    }

    return [];
  }

  @override
  Future<Routine?> getRoutine(int routineId) {
    // TODO: implement getRoutine
    throw UnimplementedError();
  }

  @override
  Future<void> markTaskCompleted(int taskId) {
    // TODO: implement markTaskCompleted
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getLooseTasks() {
    // TODO: implement getLooseTasks
    throw UnimplementedError();
  }

  @override
  Future<List<TaskGroup>> getNonRoutineTaskGroups() {
    // TODO: implement getNonRoutineTaskGroups
    throw UnimplementedError();
  }

  @override
  Future<List<Routine>> getRoutines() {
    // TODO: implement getRoutines
    throw UnimplementedError();
  }

  @override
  Future<Map<int, DateTime?>> getTaskCompletionsForDate(
      List<int> tasks, DateTime date) {
    // TODO: implement getTaskCompletionsForDate
    throw UnimplementedError();
  }
}
