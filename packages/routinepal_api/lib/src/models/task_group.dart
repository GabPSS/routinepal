import 'task.dart';

/// Represents a group of tasks that must all be completed in a day.
class TaskGroup {
  final int id;
  final String name;
  final List<TaskBase> tasks;

  TaskGroup({
    required this.id,
    required this.name,
    required this.tasks,
  });
}
