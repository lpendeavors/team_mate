import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

///
/// Message
///
@immutable
abstract class TeamsMessage {
  const TeamsMessage();
}

class TeamAddedMessage implements TeamsMessage {
  const TeamAddedMessage();
}

class TeamAddedMessageSuccess implements TeamAddedMessage {
  final String addedTeam;

  const TeamAddedMessageSuccess(this.addedTeam);
}

class TeamAddedMessageError implements TeamAddedMessage {
  final Object error;

  const TeamAddedMessageError(this.error);
}

///
/// Error
///
@immutable
abstract class TeamError {}

class TeamNameError implements TeamError {
  const TeamNameError();
}

class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class TeamListState {
  final List<TeamItem> teamItems;
  final bool isLoading;
  final Object error;

  const TeamListState({
    @required this.teamItems,
    @required this.isLoading,
    @required this.error,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamListState &&
        runtimeType == other.runtimeType &&
        isLoading == other.isLoading &&
        error == other.error &&
        const ListEquality<TeamItem>().equals(teamItems, other.teamItems);

  @override
  int get hashCode =>
      const ListEquality<TeamItem>().hash(teamItems) ^
      isLoading.hashCode ^
      error.hashCode;

  @override
  String toString() =>
    'TeamListState{teamItems: $teamItems, isLoading: $isLoading, error: $error}';

  TeamListState copyWith({teamItems, isLoading, error}) {
    return TeamListState(
      teamItems: teamItems ?? this.teamItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@immutable
class TeamItem {
  final String id;
  final String name;
  final int memberCount;

  const TeamItem({
    @required this.id,
    @required this.name,
    @required this.memberCount
  });

  @override
  String toString() => 'TeamItem{id: $id, name: $name, memberCount: $memberCount}';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TeamItem &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      memberCount == other.memberCount;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      memberCount.hashCode;
}

