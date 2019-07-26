import 'dart:async';

import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/team/firestore_team_repository.dart';
import 'package:team_mate/data/user/firebase_user_repository.dart';
import 'package:team_mate/data/project/firestore_project_repository.dart';
import 'package:team_mate/models/task_entity.dart';
import 'package:team_mate/models/team_entity.dart';
import 'package:team_mate/models/user_entity.dart';
import 'package:team_mate/models/project_entity.dart';
import 'package:team_mate/screens/team_details/team_details_state.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';


const _kInitialTeamDetailState = TeamDetailsState(
  error: null,
  isLoading: true,
  teamDetails: null,
  projectItems: <ProjectItem>[],
  memberItems: <MemberItem>[],
);

class TeamDetailsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  Function() addNewMember;
  Function() addNewProject;

  ///
  /// Output streams
  ///
  final ValueObservable<TeamDetailsState> teamDetailsState$;
  final Stream<TeamDetailMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  TeamDetailsBloc._({
    @required this.addNewMember,
    @required this.addNewProject,
    @required this.teamDetailsState$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory TeamDetailsBloc({
    @required UserBloc userBloc,
    @required FirestoreProjectRepository projectRepository,
    @required FirebaseUserRepository userRepository,
    @required FirestoreTeamRepository teamRepository,
    @required NumberFormat priceFormat,
    @required String teamId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(projectRepository != null, 'projectRepository cannot be null');
    assert(userRepository != null, 'userRepository cannot be null');
    assert(priceFormat != null, 'priceFormat cannot be null');
    assert(teamId != null, 'teamId cannot be null');

    ///
    /// Stream controllers
    ///
    // ignore: close_sinks
    final addNewMember = PublishSubject<String>(sync: true);
    // ignore: close_sinks
    final addNewProject = PublishSubject<String>(sync: true);

    ///
    /// Streams
    ///
    final message$ = _getTeamDetailMessage(
      addNewMember,
      addNewProject,
      userBloc,
      projectRepository,
      teamRepository,
    );

    final teamDetailState$ = Observable.combineLatest2<TeamDetailsState,
        TeamDetailMessage, TeamDetailsState>(
      _getTeamDetails(
        userBloc,
        teamRepository,
        projectRepository,
        userRepository,
        priceFormat,
        teamId
      ),
      message$
        .where((message) => message is TeamMemberAddedMessageError || message is TeamProjectAddedMessageError)
        .startWith(null),
      (details, error) {
          print(
            '[DEBUG] emit latest state when error occurred $error projects=${details.projectItems.length},'
                ' members=${details.memberItems.length}}'
          );
          return details;
        },
    ).publishValueSeeded(_kInitialTeamDetailState);

    final subscriptions = <StreamSubscription>[
      teamDetailState$.connect(),
      message$.connect(),
    ];

    return TeamDetailsBloc._(
      addNewMember: () => addNewMember.add(null),
      addNewProject: () => addNewProject.add(null),
      teamDetailsState$: teamDetailState$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
//        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  @override void dispose() => _dispose();

  static Observable<TeamDetailsState> _toState(
    LoginState loginState,
    FirestoreProjectRepository projectRepository,
    FirestoreTeamRepository teamRepository,
    FirebaseUserRepository userRepository,
    NumberFormat priceFormat,
    String teamId,
  ) {
    if (loginState is Unauthenticated) {
      return Observable.just(
        _kInitialTeamDetailState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Observable.zip3(
          teamRepository.teamById(teamId: teamId),
          projectRepository.projectsByTeam(teamId: teamId),
          userRepository.getUsersByTeam(teamId: teamId),
          (team, projects, members) {
            return _kInitialTeamDetailState.copyWith(
              teamDetails: _teamDetailEntityToItem(team),
              projectItems: _projectEntitiesToProjectItems(projects, priceFormat),
              memberItems: _memberEntitiesToMemberItems(members, priceFormat),
              isLoading: false,
            );
          }
        )
        .startWith(_kInitialTeamDetailState)
        .onErrorReturnWith((e) {
          return _kInitialTeamDetailState.copyWith(
            error: e,
            isLoading: false,
          );
        });
    }

    return Observable.just(
      _kInitialTeamDetailState.copyWith(
        error: "Dont know the loginState=$loginState",
        isLoading: false,
      ),
    );
  }

  static TeamDetailItem _teamDetailEntityToItem(
    TeamEntity entity
  ) {
    return TeamDetailItem(
      id: entity.id,
      name: entity.name,
    );
  }

  static List<ProjectItem> _projectEntitiesToProjectItems(
    List<ProjectEntity> entities,
    NumberFormat priceFormat,
  ) {
    return entities.map((entity) {
      return ProjectItem(
        id: entity.id,
        name: entity.name,
        dueDate: DateFormat.yMMMd().format(entity.dueDate.toDate()),
      );
    }).toList();
  }

  static List<MemberItem> _memberEntitiesToMemberItems(
    List<UserEntity> entities,
    NumberFormat priceFormat,
  ) {
    return entities.map((entity) {
      return MemberItem(
        id: entity.id,
        fullName: entity.fullName,
      );
    }).toList();
  }

  static Observable<TeamDetailsState> _getTeamDetails(
    UserBloc userBloc,
    FirestoreTeamRepository teamRepository,
    FirestoreProjectRepository projectRepository,
    FirebaseUserRepository userRepository,
    NumberFormat priceFormat,
    String teamId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        projectRepository,
        teamRepository,
        userRepository,
        priceFormat,
        teamId
      );
    });
  }

  static ConnectableObservable<TeamDetailMessage> _getTeamDetailMessage(
    Observable<String> addNewMember,
    Observable<String> addNewProject,
    UserBloc userBloc,
    FirestoreProjectRepository projectRepository,
    FirestoreTeamRepository teamRepository,
  ) {
    return Observable.combineLatest([addNewMember, addNewProject], (message) {
      var loginState = userBloc.loginState$.value;
      if (loginState is Unauthenticated) {

      }

      if (loginState is LoggedInUser) {

      }
    }).publish();
  }
}