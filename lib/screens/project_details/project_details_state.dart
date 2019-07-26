import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

///
/// Message
///
@immutable
abstract class ProjectDetailMessage {}

@immutable
abstract class ProjectTaskMessage {}

@immutable
abstract class ProjectTaskAddedMessage {}

class ProjectTaskAddedMessageSuccess implements ProjectTaskAddedMessage {
  const ProjectTaskAddedMessageSuccess();
}

class ProjectTaskAddedMessageError implements ProjectTaskAddedMessage {
  const ProjectTaskAddedMessageError();
}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class ProjectDetailsState {
  final ProjectDetailItem projectDetails;
  final List<TaskItem> taskItems;
  final bool isLoading;
  final Object error;

  const ProjectDetailsState({
    @required this.projectDetails,
    @required this.taskItems,
    @required this.isLoading,
    @required this.error,
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ProjectDetailsState &&
      runtimeType == other.runtimeType &&
      projectDetails == other.projectDetails &&
      isLoading == other.isLoading &&
      error == other.error &&
      const ListEquality<TaskItem>().equals(taskItems, other.taskItems);

  @override
  int get hashCode =>
      projectDetails.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      ListEquality<TaskItem>().hash(taskItems);

  @override
  String toString() =>
      'ProjectDetailsState{projectDetails=$projectDetails, taskItems=$taskItems, isLoading=$isLoading '
          'error=$error}';

  ProjectDetailsState copyWith({projectDetails, taskItems, isLoading, error}) {
    return ProjectDetailsState(
      projectDetails: projectDetails ?? this.projectDetails,
      taskItems: taskItems ?? this.taskItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@immutable
class ProjectDetailItem {
  final String id;
  final String name;
  final String description;
  final DateTime dueDate;

  const ProjectDetailItem({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.dueDate,
  });

  @override
  String toString() =>
      'ProjectDetailItem{id=$id, name=$name, description=$description, dueDate=$dueDate}';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ProjectDetailItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      dueDate == other.dueDate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      dueDate.hashCode;
}

@immutable
class TaskItem {
  final String id;
  final String name;
  final DateTime dueDate;

  const TaskItem({
    @required this.id,
    @required this.name,
    @required this.dueDate,
  });

  @override
  String toString() =>
      'TaskItem{id=$id, name=$name, dueDate=$dueDate}';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TaskItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      dueDate == other.dueDate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      dueDate.hashCode;
}