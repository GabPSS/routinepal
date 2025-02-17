import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:routinepal_api/routinepal_api.dart' as api_lib;
import 'package:routinepal_manager/src/models/models.dart' as models;

const Null fulfillable = null;

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
    var taskCompletions = (await api.getTaskCompletionsForDate(DateTime.now()));

    routines.removeWhere((routine) =>
        routine.tasks.getStatus(taskCompletions.allFor(routine.tasks)) !=
        fulfillable);

    //TODO: Uncomment when deploying
    // routines.removeWhere((element) =>
    //     TimeOfDay.now().isNotWithin(element.fulfillmentTime, toleranceMins));

    return routines;
  }

  /// Obtains a list of all tasks and their statuses for the date [date].
  Future<List<models.Task>> getTasksFor(DateTime date) async {
    List<api_lib.TaskCompletion> taskCompletions =
        await api.getTaskCompletionsForDate(date);
    var taskGroups = await api.getNonRoutineTaskGroups();
    var looseTasks = await api.getLooseTasks();

    List<models.Task> result = [];

    for (var group in taskGroups) {
      var groupTaskCompletions = taskCompletions.allFor(group.tasks);
      result.add(models.Task(
        id: group.id,
        title: group.name,
        totalTasks: group.tasks.length,
        completedTasks: groupTaskCompletions.fulfilled.length,
        isFulfilled: group.tasks.getStatus(groupTaskCompletions),
        parentGroupId: group.id,
      ));
    }

    for (var task in looseTasks) {
      var completion = taskCompletions.forTask(task);
      result.add(models.Task(
        id: task.id,
        title: task.title,
        description: task.description,
        minDuration: task.minDuration,
        maxDuration: task.maxDuration,
        totalTasks: 1,
        completedTasks: completion != null && completion.isFulfilled ? 1 : 0,
        isFulfilled: completion?.isFulfilled,
        parentGroupId: null,
      ));
    }

    return result;
  }

  /// Obtains a list of all tasks part of a group with id [groupId].
  Future<List<models.Task>> getTasksPartOfGroup(int groupId,
      [DateTime? date]) async {
    var group = await api.getTasksPartOfGroup(groupId);
    List<models.Task> result = [];

    for (var task in group) {
      var possibleCompletion =
          await api.getSingleTaskCompletion(task.id, date ?? DateTime.now());
      result.add(models.Task(
        id: task.id,
        title: task.title,
        description: task.description,
        minDuration: task.minDuration,
        maxDuration: task.maxDuration,
        isFulfilled: possibleCompletion?.isFulfilled,
        parentGroupId: groupId,
        totalTasks: 1,
        completedTasks: possibleCompletion?.isFulfilled == true ? 1 : 0,
      ));
    }

    return result;
  }

  /// Filters a set of TaskCompletions according to a list of tasks.
  List<api_lib.TaskCompletion> taskCompletionsFor(
      List<api_lib.Task> tasks, List<api_lib.TaskCompletion> completions) {
    return completions
        .where((completion) => tasks.contains(completion.task))
        .toList();
  }

  Future<bool> attemptTaskFulfillment(models.Task task) async {
    bool isFulfillable = true;

    if (isFulfillable) {
      // Check Task already completed
      var taskCompletion = (await api.getTaskCompletionsForDate(DateTime.now()))
          .where((completion) => completion.task.id == task.id)
          .singleOrNull;

      if (taskCompletion != null) {
        log("Task not fulfillable: completion already exists");
        isFulfillable = false;
      }
    }

    if (isFulfillable) {
      // Check Routine not fulfillable
      api_lib.Routine? routine;

      if (task.parentGroupId != null) {
        routine = await api.isTaskGroupPartOfRoutine(task.parentGroupId!);
      }

      if (routine != null) {
        isFulfillable = true;
        //TODO: Uncomment when deploying
        // isFulfillable =
        //     routine.fulfillmentTime.isWithin(TimeOfDay.now(), toleranceMins);
        log("Task part of ${isFulfillable ? "" : "un"}fulfillable routine ${routine.title}");
      }
    }

    // Task fulfillment
    if (isFulfillable) {
      api.recordTaskFulfillment(task.id, true);
      log("INFO: Task fulfilled successfully");
    } else {
      log("WARNING: Task not fulfillable");
    }

    return isFulfillable;
  }

  Future<bool> attemptTaskUnfulfillment(models.Task task) async {
    log("Manager: Task unfulfillment requested for task ${task.id} with title ${task.title} part of group ${task.parentGroupId}");
    var taskCompletion = (await api.getTaskCompletionsForDate(DateTime.now()))
        .where((completion) => completion.task.id == task.id)
        .singleOrNull;

    if (taskCompletion == fulfillable) {
      api.recordTaskFulfillment(task.id, false);
      log("Task unfulfilled successfully");
      return true;
    }

    log("Task not unfulfillable: completion already exists");
    return false;
  }

  Future<void> createTask(models.Task task) async {
    var newTask = api_lib.Task(
      title: task.title,
      description: task.description,
      minDuration: task.minDuration,
      maxDuration: task.maxDuration,
      id: 0,
    );

    await api.createTask(newTask);
  }
}

extension on Iterable<api_lib.TaskCompletion> {
  Iterable<api_lib.TaskCompletion> allFor(List<api_lib.Task> tasks) =>
      where((completion) => tasks.contains(completion.task));

  api_lib.TaskCompletion? forTask(api_lib.Task task) =>
      where((completion) => completion.task == task).singleOrNull;

  Iterable<api_lib.TaskCompletion> get fulfilled =>
      where((completion) => completion.isFulfilled);
}

extension on Iterable<api_lib.Task> {
  bool? getStatus(Iterable<api_lib.TaskCompletion> completions) {
    bool? isFulfilled;

    bool thereIsAnyFailedTask =
        completions.any((completion) => !completion.isFulfilled);
    bool allTasksWereFulfilled = every((task) => completions.any(
        (completion) => completion.task == task && completion.isFulfilled));

    if (thereIsAnyFailedTask) {
      isFulfilled = !thereIsAnyFailedTask;
    } else {
      isFulfilled = allTasksWereFulfilled ? true : fulfillable;
    }

    return isFulfilled;
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

  bool isNotWithin(TimeOfDay other, int toleranceMins) {
    return other < this - toleranceMins || other > this + toleranceMins;
  }

  bool isWithin(TimeOfDay other, int toleranceMins) =>
      !isNotWithin(other, toleranceMins);
}
