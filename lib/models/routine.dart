import 'package:flutter/material.dart';
import 'package:routinepal/models/task.dart';

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
