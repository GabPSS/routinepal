import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:routinepal_api/src/routinepal_db_base.dart';
import 'package:sqflite/sqflite.dart';

import 'models/models.dart';

class RoutinepalSqliteDb implements RoutinepalApi {
  Database? _db;

  RoutinepalSqliteDb();

  @override
  Future<void> init([bool createDemoDb = false]) async {
    _db = await openDatabase(
      'routine_data.db',
      version: 2,
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
      task_group_id INTEGER, minimum_duration_min INTEGER, maximum_duration_min INTEGER,
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
      completion_time TIME NOT NULL, is_completed INTEGER NOT NULL,
      CONSTRAINT task_completions_FK FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE ON UPDATE CASCADE
    );
    """);

        await db.execute("""
    CREATE TABLE "user_info" (
      user_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      user_name TEXT NOT NULL,
      user_last_update DATETIME NOT NULL,
      user_last_reset DATETIME NOT NULL
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

          db.insert('tasks', {
            'title': 'Stretch',
            'description': 'Stretch your muscles',
            'maximum_duration_min': 10,
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
            'task_group_id': 3,
            'maximum_duration_min': 2,
            'minimum_duration_min': 2
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

          db.insert('tasks', {
            'title': 'Do a Holy Hour',
            'description': 'Spend an hour in prayer',
            'task_group_id': null,
            'minimum_duration_min': 60
          });

          db.insert('tasks', {
            'title': 'Read a Book',
            'description': 'Read a book for 30 minutes',
            'task_group_id': null,
            'maximum_duration_min': 30
          });

          db.insert('tasks', {
            'title': 'Go for a Walk',
            'description': 'Go for a walk for a while',
            'task_group_id': null,
            'minimum_duration_min': 15,
            'maximum_duration_min': 60
          });

          db.insert('tasks', {
            'title': 'Test1',
            'description': 'test1',
            'task_group_id': null,
            'minimum_duration_min': 1
          });
          db.insert('tasks', {
            'title': 'Test2',
            'description': 'test2',
            'task_group_id': null,
            'maximum_duration_min': 1
          });
          db.insert('tasks', {
            'title': 'Test3',
            'description': 'test3',
            'task_group_id': null,
            'minimum_duration_min': 1,
            'maximum_duration_min': 2
          });
        }
      },
    );
  }

  // GET functions

  @override
  Future<TaskBase?> getTask(int taskId) async {
    List<Map<String, dynamic>> results =
        await _db!.query('tasks', where: 'task_id = $taskId');

    if (results.isNotEmpty) {
      return TaskBase(
        id: results[0]['task_id'],
        title: results[0]['title'],
        description: results[0]['description'],
        minDuration: results[0]['minimum_duration_min'],
        maxDuration: results[0]['maximum_duration_min'],
      );
    }

    return null;
  }

  @override
  Future<List<TaskBase>> getAllTasks({String? where}) async {
    List<Map<String, dynamic>> results =
        await _db!.query('tasks', where: where);
    return results.map((task) {
      return TaskBase(
        id: task['task_id'],
        title: task['title'],
        description: task['description'],
        minDuration: task['minimum_duration_min'],
        maxDuration: task['maximum_duration_min'],
      );
    }).toList();
  }

  @override
  Future<List<TaskBase>> getTasksPartOfGroup(int groupId) {
    return getAllTasks(where: 'task_group_id = $groupId');
  }

  @override
  Future<List<TaskBase>> getLooseTasks() {
    return getAllTasks(where: 'task_group_id IS NULL');
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

  @override
  Future<List<TaskGroup>> getNonRoutineTaskgroups() async {
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
  Future<List<TaskCompletion>> getTaskCompletionsForDate(DateTime date) async {
    var completionData = await _db!.query('task_completions',
        where: 'completion_date = \'${DbUtils.formatSqlDate(date)}\'');

    List<TaskCompletion> completions = [];
    List<TaskBase> completedTasks = [];

    for (var completion in completionData) {
      TaskBase completionTask = (await getTask(completion['task_id'] as int))!;

      // The check below is a self-cleanup action to remove duplicated completions.
      if (!completedTasks.contains(completionTask)) {
        completedTasks.add(completionTask);

        bool isTaskFulfilled = (completion['is_completed'] as int) == 1;
        TimeOfDay completionTime =
            DbUtils.parseSqlTime(completion['completion_time'] as String);

        completions.add(TaskCompletion(
          task: completionTask,
          completionTime: completionTime,
          isFulfilled: isTaskFulfilled,
        ));
      } else {
        deleteInvalidCompletion(completion['completion_id'] as int);
      }
    }

    return completions;
  }

  @override
  Future<Routine?> getRoutineTaskgroup(int groupId) async {
    var query = await _db!.query('routines', where: 'task_group_id = $groupId');

    if (query.isNotEmpty) {
      return _buildRoutineFromData(query[0], _db!);
    }

    return null;
  }

  @override
  Future<TaskCompletion?> getSingleTaskCompletion(int taskId, DateTime date,
      [TaskBase? task]) async {
    var completions = await _db!.query('task_completions',
        where:
            'task_id = $taskId AND completion_date = \'${DbUtils.formatSqlDate(date)}\'');

    if (completions.isNotEmpty) {
      return TaskCompletion(
        task: task ?? (await getTask(taskId)) ?? TaskBase.mock(taskId),
        completionTime:
            DbUtils.parseSqlTime(completions[0]['completion_time'] as String),
        isFulfilled: (completions[0]['is_completed'] as int) == 1,
      );
    }

    return null;
  }

  Future<UserInfo?> getUserInfo() async {
    var results = await _db!.query('user_info');

    if (results.isNotEmpty) {
      return UserInfo(
        name: results[0]['user_name'] as String,
        lastUpdate: DateTime.parse(results[0]['user_last_update'] as String),
        lastReset: DateTime.parse(results[0]['user_last_reset'] as String),
      );
    }

    return null;
  }

  // CREATE functions

  @override
  Future<int?> createTask(TaskBase task, [int? groupId]) async {
    try {
      return await _db!.insert('tasks', {
        'title': task.title,
        'description': task.description,
        'task_group_id': groupId,
        'minimum_duration_min': task.minDuration,
        'maximum_duration_min': task.maxDuration,
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int?> createTaskgroup(String name) async {
    try {
      return await _db!.insert('task_groups', {'name': name});
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createTaskCompletion(int taskId, bool isFulfilled) async {
    await _db!.insert('task_completions', {
      'task_id': taskId,
      'completion_date': DbUtils.formatSqlDate(DateTime.now()),
      'completion_time': DbUtils.formatSqlTime(TimeOfDay.now()),
      'is_completed': isFulfilled ? 1 : 0,
    });
  }

  // UPDATE functions

  @override
  Future<void> assignGroupIdToTask(int taskId, int groupId) {
    return _db!.update('tasks', {'task_group_id': groupId},
        where: 'task_id = $taskId');
  }

  @override
  Future<void> updateUserInfo(UserInfo userInfo) async {
    await _db!.delete('user_info');
    await _db!.insert('user_info', {
      'user_name': userInfo.name,
      'user_last_update': userInfo.lastUpdate.toIso8601String(),
      'user_last_reset': userInfo.lastReset.toIso8601String(),
    });
  }

  // DELETE functions

  Future<void> deleteInvalidCompletion(int completionId) async {
    log("WARNING: Detected a duplicate completion entry with id $completionId");
    await _db!
        .delete('task_completions', where: 'completion_id = $completionId');
  }

  // Auxiliary functions

  Future<Routine> _buildRoutineFromData(
      Map<String, Object?> routineData, Database db) async {
    int taskGroupId = routineData['task_group_id'] as int;

    var taskGroupData = await db.query(
      'task_groups',
      where: 'group_id = $taskGroupId',
    );

    List<TaskBase> tasks = await getTasksPartOfGroup(taskGroupId);

    return Routine(
      id: routineData['routine_id'] as int,
      taskGroupId: taskGroupId,
      title: taskGroupData[0]['name'] as String,
      tasks: tasks,
      fulfillmentTime:
          DbUtils.parseSqlTime(routineData['fulfillment_time'] as String),
    );
  }
}

final class DbUtils {
  DbUtils._();

  static TimeOfDay parseSqlTime(String sqlTime) {
    var time = sqlTime.split(':');
    return TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
  }

  static String formatSqlTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  static String formatSqlDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// extension on TimeOfDay {
//   String toSqlTime() =>
//       '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
// }
