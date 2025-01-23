import 'package:routinepal/models/task.dart';

class TaskGroup {
  final int id;
  final String name;
  final List<Task> tasks;

  TaskGroup({
    required this.id,
    required this.name,
    required this.tasks,
  });
}
