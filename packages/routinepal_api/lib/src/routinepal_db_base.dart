import 'package:flutter/material.dart';
import 'package:routinepal_api/src/models/models.dart';

abstract class RoutinepalApi {
  /// Initializes the database. If it does not exist, it will be created.
  Future<void> init();

  /// Fetches a certain task with id [taskId] from the database.
  Future<Task?> getTask(int taskId);

  /// Fetches all tasks part of a [TaskGroup] with id [groupId].
  Future<List<Task>> getTasksPartOfGroup(int groupId);

  /// Fetches all tasks not part of groups.
  Future<List<Task>> getLooseTasks();

  /// Fetches all task groups which are not routines.
  Future<List<TaskGroup>> getNonRoutineTaskGroups();

  /// Fetches all routines from the database.
  Future<List<Routine>> getRoutines();

  /// Fetches a certain routine with id [routineId] from the database.
  Future<Routine?> getRoutine(int routineId);

  /// Fetches all task completions on a certain [date].
  ///
  /// If the task was completed, the returned map will contain a non-null [TimeOfDay] for the task.
  Future<Map<Task, TimeOfDay>> getTaskCompletionsForDate(DateTime date);

  // /// Creates an entry in `task_completions` for a task with id [taskId].
  // Future<void> markTaskCompleted(int taskId);
}
