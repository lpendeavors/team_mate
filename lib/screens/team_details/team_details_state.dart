import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class TeamDetailMessage {
  const TeamDetailMessage();
}

abstract class TeamProjectMessage implements TeamDetailMessage {
  const TeamProjectMessage();
}

abstract class TeamProjectAddedMessage implements TeamProjectMessage {
  const TeamProjectAddedMessage();
}

class TeamProjectAddedMessageSuccess implements TeamProjectAddedMessage {
  final String addedProjectName;

  const TeamProjectAddedMessageSuccess(this.addedProjectName);
}

class TeamProjectAddedMessageError implements TeamProjectAddedMessage {
  final Object error;

  const TeamProjectAddedMessageError(this.error);
}

abstract class TeamMemberMessage implements TeamDetailMessage {
  const TeamMemberMessage();
}

abstract class TeamMemberAddedMessage implements TeamMemberMessage {
  const TeamMemberAddedMessage();
}

class TeamMemberAddedMessageSuccess implements TeamMemberAddedMessage {
  final String memberName;

  const TeamMemberAddedMessageSuccess(this.memberName);
}

class TeamMemberAddedMessageError implements TeamMemberAddedMessage {
  final Object error;

  const TeamMemberAddedMessageError(this.error);
}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///

@immutable
class TeamDetailsState {
  final TeamDetailItem teamDetails;
  final List<ProjectItem> projectItems;
  final List<MemberItem> memberItems;
  final bool isLoading;
  final Object error;

  const TeamDetailsState({
    @required this.teamDetails,
    @required this.projectItems,
    @required this.memberItems,
    @required this.isLoading,
    @required this.error,
  });

  @override
  bool operator ==(Object other) {
    identical(this, other) ||
    other is TeamDetailsState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      error == other.error &&
      teamDetails == other.teamDetails &&
      const ListEquality<ProjectItem>().equals(projectItems, other.projectItems) &&
      const ListEquality<MemberItem>().equals(memberItems, other.memberItems);
  }

  @override
  int get hashCode =>
      const ListEquality<ProjectItem>().hash(projectItems) ^
      const ListEquality<MemberItem>().hash(memberItems) ^
      teamDetails.hashCode ^
      isLoading.hashCode ^
      error.hashCode;

  @override
  String toString() =>
    'TeamDetailsState{projectItems: $projectItems, memberItems: $memberItems, isLoading: $isLoading, error: $error'
    ' teamDetails: $teamDetails}';

  TeamDetailsState copyWith({teamDetails, projectItems, memberItems, isLoading, error}) {
    return TeamDetailsState(
      teamDetails: teamDetails ?? this.teamDetails,
      projectItems: projectItems ?? this.projectItems,
      memberItems: memberItems ?? this.memberItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@immutable
class TeamDetailItem {
  final String id;
  final String name;

  const TeamDetailItem({
    @required this.id,
    @required this.name,
  });

  @override
  String toString() =>
      'TeamDetailItem{id=$id, name=$name}';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TeamDetailItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode;
}

@immutable
class ProjectItem {
  final String id;
  final String name;
  final String dueDate;

  const ProjectItem({
    @required this.id,
    @required this.name,
    @required this.dueDate,
  });

  @override
  String toString() =>
      'ProjectItem{id=$id, name=$name, dueDate=$dueDate}';

  @override
  bool operator ==(other) =>
    identical(this, other) ||
    other is ProjectItem &&
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

@immutable
class MemberItem {
  final String id;
  final String fullName;

  const MemberItem({
    @required this.id,
    @required this.fullName,
  });

  @override
  String toString() =>
      'MemberItem{id=$id, fullname=$fullName}';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is MemberItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      fullName == other.fullName;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode;
}