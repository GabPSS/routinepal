import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

const Null fulfillable = null;

class RoutinepalManager {
  final RoutinepalApi api;
  UserInfo? _userInfo;
  int toleranceMins = 15;

  RoutinepalManager(this.api);

  /// Defines if this is the first time the user is setting up the app.
  bool get isFirstSetup => _userInfo == null;

  Future<void> init() async {
    await api.init();
    _userInfo = await api.getUserInfo();
  }

  /// Obtains a list of all routines that can be fulfilled at the current time.
  ///
  /// A routine is considered fulfillable if all of its tasks have been completed and the current time is within [toleranceMins] minutes of the routine's fulfillment time.
  Future<List<Routine>> getFulfillableRoutines() async {
    var routines = await api.getRoutines();
    var taskCompletions = (await api.getTaskCompletionsForDate(DateTime.now()));

    routines.removeWhere((routine) =>
        routine.tasks.getStatus(taskCompletions.allFor(routine.tasks)) !=
        fulfillable);

    routines.removeWhere((element) =>
        TimeOfDay.now().isNotWithin(element.fulfillmentTime, toleranceMins));

    return routines;
  }

  /// Obtains a list of all tasks and their statuses for the date [date].
  Future<List<Task>> getTasksFor(DateTime date) async {
    List<TaskCompletion> taskCompletions =
        await api.getTaskCompletionsForDate(date);
    var taskGroups = await api.getNonRoutineTaskGroups();
    var looseTasks = await api.getLooseTasks();

    List<Task> result = [];

    for (var group in taskGroups) {
      var groupTaskCompletions = taskCompletions.allFor(group.tasks);
      result.add(Task(
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
      result.add(Task(
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
  Future<List<Task>> getTasksPartOfGroup(int groupId, [DateTime? date]) async {
    var group = await api.getTasksPartOfGroup(groupId);
    List<Task> result = [];

    for (var task in group) {
      var possibleCompletion =
          await api.getSingleTaskCompletion(task.id, date ?? DateTime.now());
      result.add(Task(
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

  Future<List<String>> getAllTaskNames() async {
    var tasks = await api.getAllTasks();
    return tasks.map((task) => task.title).toList();
  }

  /// Obtains a list of all task completions for the last [numberOfDays] days.
  Future<Map<DateTime, Map<TaskBase, TaskCompletion?>>> getCompletionHistory(
      int numberOfDays) async {
    var initialDate = DateTime.now().subtract(Duration(days: numberOfDays));
    var currentDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .add(Duration(days: 1));
    var allTasks = await api.getAllTasks();
    allTasks.sort((a, b) => a.id.compareTo(b.id));

    Map<DateTime, Map<TaskBase, TaskCompletion?>> result = {};
    Map<TaskBase, TaskCompletion?> completionsForDate;

    for (var iteratingDate = initialDate;
        iteratingDate.isBefore(currentDate);
        iteratingDate = iteratingDate.add(Duration(days: 1))) {
      List<TaskCompletion> completions =
          await api.getTaskCompletionsForDate(iteratingDate);
      log("Manager: Completion history for date $iteratingDate has ${completions.length} completions");

      completionsForDate = {};

      for (var task in allTasks) {
        var completion = completions.forTask(task);
        completionsForDate[task] = completion;
      }

      result[iteratingDate] = completionsForDate;
    }

    return result;
  }

  /// Filters a set of TaskCompletions according to a list of tasks.
  List<TaskCompletion> filterCompletions(
          List<TaskBase> tasks, List<TaskCompletion> completions) =>
      completions
          .where((completion) => tasks.contains(completion.task))
          .toList();

  Future<bool> attemptTaskFulfillment(Task task) async {
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
      Routine? routine;

      if (task.parentGroupId != null) {
        routine = await api.isTaskGroupPartOfRoutine(task.parentGroupId!);
      }

      if (routine != null) {
        isFulfillable = true;

        isFulfillable =
            routine.fulfillmentTime.isWithin(TimeOfDay.now(), toleranceMins);
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

  Future<bool> attemptTaskUnfulfillment(Task task) async {
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

  Future<void> createTask(Task task) async {
    var newTask = TaskBase(
      title: task.title,
      description: task.description,
      minDuration: task.minDuration,
      maxDuration: task.maxDuration,
      id: 0,
    );

    await api.createTask(newTask);
  }
}

extension on Iterable<TaskCompletion> {
  Iterable<TaskCompletion> allFor(List<TaskBase> tasks) =>
      where((completion) => tasks.contains(completion.task));

  TaskCompletion? forTask(TaskBase task) =>
      where((completion) => completion.task == task).singleOrNull;

  Iterable<TaskCompletion> get fulfilled =>
      where((completion) => completion.isFulfilled);
}

extension on Iterable<TaskBase> {
  bool? getStatus(Iterable<TaskCompletion> completions) {
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
