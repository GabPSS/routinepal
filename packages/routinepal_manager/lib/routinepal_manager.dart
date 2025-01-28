import 'package:flutter/material.dart';
import 'package:routinepal_api/routinepal_api.dart';

class RoutinepalManager {
  final RoutinepalApi api;
  int toleranceMins = 15;

  RoutinepalManager(this.api);

  Future<void> init() async {
    await api.init();
  }

  /// Obtains a list of all routines that can be fulfilled at the current time.
  ///
  /// A routine is considered fulfillable if all of its tasks have been completed and the current time is within [toleranceMins] minutes of the routine's fulfillment time.
  Future<List<Routine>> getFulfillableRoutines() async {
    var routines = await api.getRoutines();
    var taskCompletions = await api.getTaskCompletionsForDate(DateTime.now());

    routines.removeWhere((routine) =>
        routine.tasks.every((task) => taskCompletions.containsKey(task)));

    routines.removeWhere((element) =>
        TimeOfDay.now() < element.fulfillmentTime - toleranceMins ||
        TimeOfDay.now() > element.fulfillmentTime + toleranceMins);

    return routines;
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
