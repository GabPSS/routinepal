import 'package:routinepal/models/routine.dart';
import 'package:routinepal/models/summary.dart';
import 'package:routinepal/models/task.dart';
import 'package:routinepal/models/task_group.dart';
import 'package:sqflite/sqflite.dart';

class Api {
  static final Api _instance = Api._();

  factory Api() => _instance;

  Api._();

  Database? _database;

  Future<void> init() async {
    _database = await openDatabase(
      'routine_data.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
-- task_groups definition

CREATE TABLE task_groups (
	group_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	name TEXT
);


-- tasks definition

CREATE TABLE "tasks" (
	task_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	title TEXT NOT NULL,
	description TEXT,
	task_group_id INTEGER,
	CONSTRAINT task_definitions_FK FOREIGN KEY (task_group_id) REFERENCES task_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- routines definition

CREATE TABLE routines (
	routine_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	task_group_id INTEGER NOT NULL,
	fulfillment_time TIME NOT NULL,
	title TEXT NOT NULL,
	CONSTRAINT routines_FK FOREIGN KEY (task_group_id) REFERENCES task_groups(group_id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- task_completions definition

CREATE TABLE task_completions (
	completion_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	task_id INTEGER NOT NULL,
	completion_date DATE NOT NULL,
	completion_time TIME NOT NULL,
	CONSTRAINT task_completions_FK FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE ON UPDATE CASCADE
);
""");
      },
    );
  }

  Future<Summary?> getSummary() async {
    final List<Map<String, dynamic>> taskGroups =
        await _database!.query('task_groups');
    final List<Map<String, dynamic>> tasks = await _database!.query('tasks');
    final List<Map<String, dynamic>> routines =
        await _database!.query('routines');

    return Summary(
      taskGroups: taskGroups.map((taskGroup) {
        return TaskGroup(
          id: taskGroup['group_id'],
          name: taskGroup['name'],
          tasks: tasks
              .where((task) => task['task_group_id'] == taskGroup['group_id'])
              .map((task) {
            return Task(
              id: task['task_id'],
              title: task['title'],
              description: task['description'],
            );
          }).toList(),
        );
      }).toList(),
      routines: routines.map((routine) {
        return Routine(
          id: routine['routine_id'],
          title: routine['title'],
          fulfillmentTime: routine['fulfillment_time'],
          tasks: tasks
              .where(
                  (task) => task['task_group_id'] == routine['task_group_id'])
              .map((task) {
            return Task(
              id: task['task_id'],
              title: task['title'],
              description: task['description'],
            );
          }).toList(),
        );
      }).toList(),
      tasks: tasks
          .where((task) =>
              task['task_group_id'] == null &&
              routines.every((routine) =>
                  routine['task_group_id'] != task['task_group_id']))
          .map((task) {
        return Task(
          id: task['task_id'],
          title: task['title'],
          description: task['description'],
        );
      }).toList(),
    );
  }
}
