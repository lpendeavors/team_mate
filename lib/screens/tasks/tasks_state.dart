import 'package:meta/meta.dart';

enum CompletedIconState { showComplete, showNotComplete }

enum SeeAllQuery { newest, dueDate }

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class TaskItem {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final CompletedIconState completedState;

  const TaskItem({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.dueDate,
    @required this.completedState,
  });

  @override
  String toString() => 'TaskItem{id: $id, title: $title, description: $description, completedState: $completedState '
    'dueDate: $dueDate';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TaskItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      title == other.title &&
      description == other.description &&
      completedState == other.completedState &&
      dueDate == other.dueDate;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      completedState.hashCode ^
      dueDate.hashCode;

  TaskItem withCompletedState(CompletedIconState completedState) {
    return TaskItem(
      completedState: completedState,
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
    );
  }
}

@immutable
abstract class TasksMessage {
  const TasksMessage();
}

abstract class TaskCompletedMessage {
  const TaskCompletedMessage();
}

