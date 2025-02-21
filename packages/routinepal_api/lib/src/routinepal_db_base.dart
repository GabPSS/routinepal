import 'package:routinepal_api/src/models/models.dart';

abstract class RoutinepalApi {
  /// Initializes the database. If it does not exist, it will be created.
  Future<void> init();

  /// Fetches a certain task with id [taskId] from the database.
  Future<TaskBase?> getTask(int taskId);

  /// Creates a new task with the given data.
  Future<int?> createTask(TaskBase task, [int? groupId]);

  /// Creates a new task group with the given [name].
  Future<int?> createTaskGroup(String name);

  /// Assigns a task with id [taskId] to a group with id [groupId].
  Future<void> assignTaskToGroup(int taskId, int groupId);

  /// Fetches all tasks part of a [TaskGroup] with id [groupId].
  Future<List<TaskBase>> getTasksPartOfGroup(int groupId);

  /// Fetches all tasks not part of groups.
  Future<List<TaskBase>> getLooseTasks();

  /// Fetches all completable tasks from the database.
  Future<List<TaskBase>> getAllTasks();

  /// Fetches all task groups which are not routines.
  Future<List<TaskGroup>> getNonRoutineTaskGroups();

  /// Fetches all routines from the database.
  Future<List<Routine>> getRoutines();

  Future<Routine?> isTaskGroupPartOfRoutine(int groupId);

  /// Fetches a certain routine with id [routineId] from the database.
  Future<Routine?> getRoutine(int routineId);

  /// Fetches all task completion information for a certain [date].
  Future<List<TaskCompletion>> getTaskCompletionsForDate(DateTime date);

  /// Fetches all task completions for a certain task with id [taskId] on a certain [date].
  Future<TaskCompletion?> getSingleTaskCompletion(int taskId, DateTime date);

  /// Creates an entry in `task_completions` for a task with id [taskId].
  Future<void> recordTaskFulfillment(int taskId, bool isFulfilled);

  /// Obtains information regarding the current user of the app. If the app was not set up, returns null.
  Future<UserInfo?> getUserInfo();
}
