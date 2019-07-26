import 'package:meta/meta.dart';

///
/// ProjectMessage
///

@immutable
abstract class ProjectMessage {}

@immutable
abstract class ProjectDetailsMessage implements ProjectMessage {
  const ProjectDetailsMessage();
}

@immutable
abstract class ProjectAddedMessage implements ProjectMessage {}

class ProjectAddedMessageSuccess implements ProjectAddedMessage {
  final String projectName;

  const ProjectAddedMessageSuccess(this.projectName);
}

class ProjectAddedMessageError implements ProjectAddedMessage {
  final Object error;

  const ProjectAddedMessageError(this.error);
}

@immutable
abstract class ProjectEditedMessage implements ProjectMessage {}

class ProjectEditedMessageSuccess implements ProjectEditedMessage {
  final String projectName;

  const ProjectEditedMessageSuccess(this.projectName);
}

class ProjectEditedMessageError implements ProjectEditedMessage {
  final Object error;

  const ProjectEditedMessageError(this.error);
}

@immutable
abstract class ProjectError {}

class ProjectNameError implements ProjectError {
  const ProjectNameError();
}

class ProjectDescriptionError implements ProjectError {
  const ProjectDescriptionError();
}

class ProjectDueDateError implements ProjectError {
  const ProjectDueDateError();
}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class ProjectDetailsState {
  final ProjectAddEditItem projectDetails;
  final bool isLoading;
  final Object error;

  const ProjectDetailsState({
    @required this.projectDetails,
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
      error == other.error;

  @override
  int get hashCode =>
      projectDetails.hashCode ^
      isLoading.hashCode ^
      error.hashCode;

  @override
  String toString() =>
      'ProjectDetailsState{projectDetails=$projectDetails, isLoading=$isLoading ,error=$error}';

  ProjectDetailsState copyWith({projectDetails, isLoading, error}) {
    return ProjectDetailsState(
      projectDetails: projectDetails ?? this.projectDetails,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@immutable
class ProjectAddEditItem {
  final String id;
  final String name;
  final String description;
  final DateTime dueDate;

  const ProjectAddEditItem({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.dueDate,
  });

  @override
  String toString() =>
      'ProjectAddEditItem{id=$id, name=$name, desciption=$description, dueDate=$dueDate}';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ProjectAddEditItem &&
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