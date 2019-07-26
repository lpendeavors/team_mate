import 'package:meta/meta.dart';

///
/// Message
///
@immutable
abstract class TaskDetailMessage {}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class TaskDetailsState {
  final TaskDetailItem taskDetails;
  final bool isLoading;
  final Object error;

  const TaskDetailsState({
    @required this.taskDetails,
    @required this.isLoading,
    @required this.error,
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TaskDetailsState &&
      runtimeType == other.runtimeType &&
      taskDetails == other.taskDetails &&
      isLoading == other.isLoading &&
      error == other.error;

  @override
  int get hashCode =>
      taskDetails.hashCode ^
      isLoading.hashCode ^
      error.hashCode;

  @override
  String toString() =>
      'TaskDetailsState{taskDetails=$taskDetails, isLoading=$isLoading, error=$error}';

  TaskDetailsState copyWith({taskDetails, isLoading, error}) {
    return TaskDetailsState(
      taskDetails: taskDetails ?? this.taskDetails,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@immutable
class TaskDetailItem {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String assignee;

  const TaskDetailItem({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.dueDate,
    @required this.assignee,
  });

  @override
  String toString() =>
      'TaskDetailItem{id=$id, title=$title, description=$description, dueDate=$dueDate '
          'assignee=$assignee';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TaskDetailItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      title == other.title &&
      description == other.description &&
      dueDate == other.dueDate &&
      assignee == other.assignee;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      assignee.hashCode;
}