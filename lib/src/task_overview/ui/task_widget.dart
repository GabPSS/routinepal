import 'package:flutter/material.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

class TaskWidget extends StatelessWidget {
  final Task task;
  final Color? color;
  final double? fontSize;
  final Function()? onTaskTapped;

  const TaskWidget(
    this.task, {
    this.color,
    this.onTaskTapped,
    this.fontSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTaskTapped,
      textColor: color,
      iconColor: color,
      title: Text(
        task.title,
        textScaler: TextScaler.linear(fontSize ?? 1),
      ),
      subtitle: Text(task.description),
      leading: Hero(
        tag: 'task-${task.id}',
        child: Icon(
          switch (task.isFulfilled) {
            true => Icons.check_circle,
            false => Icons.error,
            null => Icons.circle_outlined,
          },
          size: 48,
        ),
      ),
    );
  }
}
