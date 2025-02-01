import 'package:flutter/material.dart';
import 'package:routinepal_api/routinepal_api.dart' as api_lib;
import 'package:routinepal_manager/src/models/models.dart' as models;

class RoutinepalManager {
  final api_lib.RoutinepalApi api;
  int toleranceMins = 15;

  RoutinepalManager(this.api);

  Future<void> init() async {
    await api.init();
  }

  /// Obtains a list of all routines that can be fulfilled at the current time.
  ///
  /// A routine is considered fulfillable if all of its tasks have been completed and the current time is within [toleranceMins] minutes of the routine's fulfillment time.
  Future<List<api_lib.Routine>> getFulfillableRoutines() async {
    var routines = await api.getRoutines();
    var taskCompletions = await api.getTaskCompletionsForDate(DateTime.now());

    routines.removeWhere((routine) =>
        routine.tasks.every((task) => taskCompletions.containsKey(task)));

    routines.removeWhere((element) =>
        TimeOfDay.now() < element.fulfillmentTime - toleranceMins ||
        TimeOfDay.now() > element.fulfillmentTime + toleranceMins);

    return routines;
  }

  /// Obtains a list of all tasks and their statuses for the date [date].
  Future<List<models.Task>> getTasksFor(DateTime date) async {
    var taskCompletions = await api.getTaskCompletionsForDate(date);
    var taskGroups = await api.getNonRoutineTaskGroups();
    var tasks = await api.getLooseTasks();

    List<models.Task> result = [];

    for (var group in taskGroups) {
      int completedTasks =
          group.tasks.where((task) => taskCompletions.containsKey(task)).length;
      int totalTasks = group.tasks.length;
      result.add(models.Task(
          id: group.id,
          title: group.name,
          totalTasks: totalTasks,
          completedTasks: completedTasks));
    }

    for (var task in tasks) {
      result.add(models.Task(
          id: task.id,
          title: task.title,
          description: task.description,
          totalTasks: 1,
          completedTasks: taskCompletions.containsKey(task) ? 1 : 0));
    }

    return result;
  }
}

extension on TimeOfDay {
  bool operator <(TimeOfDay other) {
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  TimeOfDay operator -(int minutes) {
    var newHour = hour;
    var newMinute = minute - minutes;

    if (newMinute < 0) {
      newHour--;
      newMinute += 60;
      if (newHour < 0) {
        newHour += 24;
      }
    }

    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  TimeOfDay operator +(int minutes) {
    var newHour = hour;
    var newMinute = minute + minutes;

    if (newMinute >= 60) {
      newHour++;
      newMinute -= 60;
      if (newHour >= 24) {
        newHour -= 24;
      }
    }

    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  bool operator >(TimeOfDay other) {
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }
}
