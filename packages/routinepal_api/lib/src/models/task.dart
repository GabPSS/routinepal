import 'package:equatable/equatable.dart';

/// A basic task model class
class Task extends Equatable {
  final int id;
  final String title;
  final String description;
  final int? minDuration;
  final int? maxDuration;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.minDuration,
    required this.maxDuration,
  });

  const Task.mock(this.id)
      : title = '',
        description = '',
        minDuration = null,
        maxDuration = null;

  @override
  List<Object?> get props => [id, title, description];
}
