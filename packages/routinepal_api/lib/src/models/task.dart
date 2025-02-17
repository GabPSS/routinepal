import 'package:equatable/equatable.dart';

/// A basic task model class
class TaskBase extends Equatable {
  final int id;
  final String title;
  final String description;
  final int? minDuration;
  final int? maxDuration;

  const TaskBase({
    required this.id,
    required this.title,
    required this.description,
    required this.minDuration,
    required this.maxDuration,
  });

  const TaskBase.mock(this.id)
      : title = '',
        description = '',
        minDuration = null,
        maxDuration = null;

  @override
  List<Object?> get props => [id, title, description];
}
