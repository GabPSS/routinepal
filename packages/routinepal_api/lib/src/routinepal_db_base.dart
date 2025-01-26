import 'package:routinepal_api/src/models/models.dart';

import 'models/task_completion.dart';

abstract class RoutinepalDbBase {
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

  /// Fetches all routines that can be fulfilled at the current time.
  ///
  /// Since this method is to be called only when probing for any fulfillable routines in the current moment, it is safe to assume the `fulfillment_time` to be the current time.
  Future<List<Routine>> getFulfillableRoutines();

  /// Fetches all routines from the database.
  Future<List<Routine>> getRoutines();

  /// Fetches a certain routine with id [routineId] from the database.
  Future<Routine?> getRoutine(int routineId);

  /// Fetches all task completions for tasks with IDs [tasks] on a certain [date].
  ///
  /// If the task was completed, the returned map will contain a non-null [DateTime] for the task ID.
  Future<Map<int, DateTime?>> getTaskCompletionsForDate(
      List<int> tasks, DateTime date);

  // /// Creates an entry in `task_completions` for a task with id [taskId].
  // Future<void> markTaskCompleted(int taskId);
}
