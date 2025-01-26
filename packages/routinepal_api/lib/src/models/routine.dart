import 'package:flutter/material.dart';
import 'package:routinepal_api/src/models/task_group.dart';
import 'task.dart';

/// A basic model for a routine. A routine is composed of a [TaskGroup] that must be completed in a specific time of day.
class Routine {
  final int id;
  final List<Task> tasks;
  final String title;
  final TimeOfDay fulfillmentTime;

  Routine({
    required this.id,
    required this.tasks,
    required this.title,
    required this.fulfillmentTime,
  });
}
