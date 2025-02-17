import 'package:flutter/material.dart';
import 'package:routinepal_api/src/models/task.dart';

/// Represents a completion of a task.
///
/// If a task is completed, [isFulfilled] is true, otherwise it's false.
///
/// If a task was neither fulfilled nor failed, the [TaskCompletion] entry for that day should not exist for the task.
class TaskCompletion {
  final TaskBase task;
  final TimeOfDay completionTime;
  final bool isFulfilled;

  TaskCompletion({
    required this.task,
    required this.completionTime,
    required this.isFulfilled,
  });
}
