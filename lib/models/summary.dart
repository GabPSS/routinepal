import 'package:routinepal/models/routine.dart';
import 'package:routinepal/models/task.dart';
import 'package:routinepal/models/task_group.dart';

/// A class containing a all the routines, groups of tasks and loose tasks the user must complete in a day.
class Summary {
  final List<Routine> routines;
  final List<TaskGroup> taskGroups;
  final List<Task> tasks;

  Summary({
    required this.routines,
    required this.taskGroups,
    required this.tasks,
  });
}
