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

  static String getDayPeriod(DateTime value) {
    var hour = value.hour;
    return switch (hour) {
      > 22 => 'night',
      > 18 => 'evening',
      > 12 => 'afternoon',
      > 6 => 'morning',
      _ => 'night',
    };
  }
}
