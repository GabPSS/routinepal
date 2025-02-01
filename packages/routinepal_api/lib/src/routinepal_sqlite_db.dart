import 'package:flutter/material.dart';
import 'package:routinepal_api/src/routinepal_db_base.dart';
import 'package:sqflite/sqflite.dart';

import 'models/models.dart';

class RoutinepalSqliteDb implements RoutinepalApi {
  Database? _db;

  RoutinepalSqliteDb();

  //TODO: Set [createDemoDb] to false when deploying
  @override
  Future<void> init([bool createDemoDb = true]) async {
    _db = await openDatabase(
      'routine_data.db',
      version: 1,
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

        if (createDemoDb) {
          db.insert('task_groups', {'name': 'Eat Well'});

          db.insert('tasks', {
            'title': 'Lunch',
            'description': 'Eat well for lunch',
            'task_group_id': 1
          });

          db.insert('tasks', {
            'title': 'Dinner',
            'description': 'Eat well for dinner',
            'task_group_id': 1
          });

          db.insert('task_groups', {'name': 'Exercise'});

          db.insert('tasks', {
            'title': 'Run',
            'description': 'Go for a run',
            'task_group_id': 2
          });

          db.insert('tasks', {
            'title': 'Lift',
            'description': 'Lift weights',
            'task_group_id': 2
          });

          db.insert('task_groups', {'name': 'Morning Routine'});

          db.insert('routines', {
            'task_group_id': 3,
            'fulfillment_time': '08:00:00',
          });

          db.insert('tasks', {
            'title': 'Brush Teeth',
            'description': 'Brush your teeth',
            'task_group_id': 3
          });

          db.insert('tasks', {
            'title': 'Shower',
            'description': 'Take a shower',
            'task_group_id': 3
          });

          db.insert('tasks', {
            'title': 'Eat Breakfast',
            'description': 'Eat a good breakfast',
            'task_group_id': 3
          });

          db.insert('tasks', {
            'title': 'Lectio Divina',
            'description': 'Meditate on the word of God for 10 minutes',
            'task_group_id': null
          });
        }
      },
    );
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
  Future<List<Routine>> getRoutines() async {
    var db = _db!;

    List<Map<String, Object?>> results = await db.query('routines');

    List<Routine> routines = [];

    for (var routineData in results) {
      routines.add(await _buildRoutineFromData(routineData, db));
    }

    return routines;
  }

  @override
  Future<Routine?> getRoutine(int routineId) {
    // TODO: implement getRoutine
    throw UnimplementedError();
  }

  Future<Routine> _buildRoutineFromData(
      Map<String, Object?> routineData, Database db) async {
    int taskGroupId = routineData['task_group_id'] as int;

    var taskGroupData = await db.query(
      'task_groups',
      where: 'group_id = $taskGroupId',
    );

    List<Task> tasks = await getTasksPartOfGroup(taskGroupId);

    return Routine(
      id: routineData['routine_id'] as int,
      taskGroupId: taskGroupId,
      title: taskGroupData[0]['name'] as String,
      tasks: tasks,
      fulfillmentTime:
          DbUtils.parseSqlTime(routineData['fulfillment_time'] as String),
    );
  }

  @override
  Future<List<Task>> getLooseTasks() async {
    var taskData = await _db!.query('tasks', where: 'task_group_id IS NULL');

    return taskData.map((task) {
      return Task(
        id: task['task_id'] as int,
        title: task['title'] as String,
        description: task['description'] as String,
      );
    }).toList();
  }

  @override
  Future<List<TaskGroup>> getNonRoutineTaskGroups() async {
    var taskGroupData = await _db!.rawQuery(
        'SELECT * FROM task_groups WHERE group_id NOT IN (SELECT task_group_id FROM routines)');

    List<TaskGroup> taskGroups = [];

    for (var group in taskGroupData) {
      taskGroups.add(TaskGroup(
        id: group['group_id'] as int,
        name: group['name'] as String,
        tasks: await getTasksPartOfGroup(group['group_id'] as int),
      ));
    }

    return taskGroups;
  }

  @override
  Future<Map<Task, TimeOfDay>> getTaskCompletionsForDate(DateTime date) async {
    var completionData = await _db!.query('task_completions',
        where: 'completion_date = ${DbUtils.formatSqlDate(date)}');

    Map<Task, TimeOfDay> completions = {};

    for (var completion in completionData) {
      var task = await getTask(completion['task_id'] as int);
      if (task != null) {
        completions[task] =
            DbUtils.parseSqlTime(completion['completion_time'] as String);
      }
    }

    return completions;
  }
}

final class DbUtils {
  DbUtils._();

  static TimeOfDay parseSqlTime(String sqlTime) {
    var time = sqlTime.split(':');
    return TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
  }

  static String formatSqlDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// extension on TimeOfDay {
//   String toSqlTime() =>
//       '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
// }
