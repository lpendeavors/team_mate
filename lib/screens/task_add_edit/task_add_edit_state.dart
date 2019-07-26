import 'package:meta/meta.dart';

///
/// TaskMessage
///

@immutable
abstract class TaskMessage {}

@immutable
abstract class TaskDetailsMessage implements TaskMessage {
  const TaskDetailsMessage();
}

@immutable
abstract class TaskAddedMessage implements TaskMessage {}

class TaskAddedMessageSuccess implements TaskAddedMessage {
  final String taskName;

  const TaskAddedMessageSuccess(this.taskName);
}

class TaskAddedMessageError implements TaskAddedMessage {
  final Object error;

  const TaskAddedMessageError(this.error);
}

@immutable
abstract class TaskEditedMessage implements TaskMessage {}

class TaskEditedMessageSuccess implements TaskEditedMessage {
  final String taskName;

  const TaskEditedMessageSuccess(this.taskName);
}

class TaskEditedMessageError implements TaskEditedMessage {
  final Object error;

  const TaskEditedMessageError(this.error);
}

@immutable
abstract class TaskError {}

class TaskTitleError implements TaskError {
  const TaskTitleError();
}

class TaskDescriptionError implements TaskError {
  const TaskDescriptionError();
}

class TaskDueDateError implements TaskError {
  const TaskDueDateError();
}

class TaskAssigneeError implements TaskError {
  const TaskAssigneeError();
}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class TaskDetailsState {
  final TaskAddEditItem taskDetails;
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
class TaskAddEditItem {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;

  const TaskAddEditItem({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.dueDate,
  });

  @override
  String toString() =>
      'TaskAddEditItem{id=$id, title=$title, description=$description, dueDate=$dueDate}';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TaskAddEditItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      title == other.title &&
      description == other.description &&
      dueDate == other.dueDate;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dueDate.hashCode;
}