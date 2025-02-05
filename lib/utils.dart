import 'package:flutter/material.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

abstract final class Utils {
  static DateTime today() {
    var today = DateTime.now();
    return DateTime(today.year, today.month, today.day);
  }

  static IconData getTaskStatusIcon(Task task) {
    return switch (task.isFulfilled) {
      true => Icons.check_circle,
      false => Icons.error,
      null => Icons.circle_outlined,
    };
  }
}
