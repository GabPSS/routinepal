import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String description;
  final int? minDuration;
  final int? maxDuration;
  final int totalTasks;
  final int completedTasks;
  final bool? isFulfilled;

  const Task({
    required this.id,
    required this.title,
    String? description,
    this.minDuration,
    this.maxDuration,
    required this.totalTasks,
    required this.isFulfilled,
    required this.completedTasks,
  }) : description = description ?? "$completedTasks of $totalTasks completed";

  const Task.mock(this.id)
      : title = "",
        description = "",
        minDuration = null,
        maxDuration = null,
        totalTasks = 0,
        isFulfilled = false,
        completedTasks = 0;

  bool get isGroup => totalTasks > 1;

  Task get fulfilled => Task(
        id: id,
        title: title,
        description: description,
        minDuration: minDuration,
        maxDuration: maxDuration,
        totalTasks: totalTasks,
        isFulfilled: true,
        completedTasks: totalTasks,
      );

  Task get unfulfilled => Task(
        id: id,
        title: title,
        description: description,
        minDuration: minDuration,
        maxDuration: maxDuration,
        totalTasks: totalTasks,
        isFulfilled: false,
        completedTasks: completedTasks,
      );

  @override
  List<Object?> get props =>
      [id, title, description, totalTasks, completedTasks];
}
