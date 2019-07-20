import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/team/firestore_team_repository.dart';
import 'package:team_mate/models/team_entity.dart';
import 'package:team_mate/screens/teams/teams_state.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialTeamListState = TeamListState(
  error: null,
  isLoading: true,
  teamItems: <TeamItem>[],
);

bool _isValidTeamName(String name) {
  return name.length >= 3;
}

class TeamsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final Function() addNewTeam;
  final Function(String) teamNameChanged;

  ///
  /// Output streams
  ///
  final ValueObservable<TeamListState> teamListState$;
  final Stream<TeamNameError> teamNameError$;
  final Stream<TeamsMessage> addedMessage$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  TeamsBloc._({
    @required this.addNewTeam,
    @required this.teamNameChanged,
    @required this.teamNameError$,
    @required this.teamListState$,
    @required this.addedMessage$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory TeamsBloc({
    @required UserBloc userBloc,
    @required FirestoreTeamRepository teamRepository,
    @required NumberFormat priceFormat,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(teamRepository != null, 'teamRepository cannot be null');
    assert(priceFormat != null, 'priceFormat cannot be null');

    ///
    /// Stream controllers
    ///
    // ignore: close_sinks
    final teamNameSubject = BehaviorSubject<String>.seeded('');
    // ignore: close_sinks
    final newTeamSubject = PublishSubject<String>(sync: true);

    ///
    /// Streams
    ///
    final teamNameError$ = teamNameSubject.map((teamName) {
      if (_isValidTeamName(teamName)) return null;
      return const TeamNameError();
    }).share();

    final allFieldsAreValid$ = Observable.combineLatest(
      [
        teamNameError$,
      ],
      (allError) => allError.every((error) => error == null),
    );

    final message$ = newTeamSubject
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => _getAddedMessage(
          teamNameSubject.value,
          userBloc,
          teamRepository,
        ),
      )
      .publish();

    final teamListState$ = Observable.combineLatest2<TeamListState, TeamAddedMessage, TeamListState>(
      _getTeamList(
        userBloc,
        teamRepository,
        priceFormat,
      ),
      message$
        .where((message) => message is TeamAddedMessageError)
        .startWith(null),
      (list, error) {
        print(
          '[DEBUG] emit latest state when error occurred $error list.length=${list.teamItems.length}'
        );
        return list;
      },
    ).publishValueSeeded(_kInitialTeamListState);

    final subscriptions = <StreamSubscription>[
      teamListState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      teamNameSubject,
    ];

    return TeamsBloc._(
      addNewTeam: () => newTeamSubject.add(null),
      teamNameChanged: teamNameSubject.add,
      addedMessage$: message$,
      teamListState$: teamListState$,
      teamNameError$: teamNameError$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  @override
  void dispose() => _dispose();

  static Observable<TeamListState> _toState(
    LoginState loginState,
    FirestoreTeamRepository teamRepository,
    NumberFormat priceFormat
  ) {
    if (loginState is Unauthenticated) {
      return Observable.just(
        _kInitialTeamListState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }
    if (loginState is LoggedInUser) {
      return Observable(teamRepository.teamsByUser(userId: loginState.uid))
        .map((entities) {
          return _entitiesToTeamItems(
            entities,
            priceFormat,
            loginState.uid,
          );
        })
        .map((teamItems) {
          return _kInitialTeamListState.copyWith(
            teamItems: teamItems,
            isLoading: false,
          );
        })
        .startWith(_kInitialTeamListState)
        .onErrorReturnWith((e) {
          return _kInitialTeamListState.copyWith(
            error: e,
            isLoading: false,
          );
        });
    }
    return Observable.just(
      _kInitialTeamListState.copyWith(
        error: "Dont know loginState=$loginState",
        isLoading: false,
      ),
    );
  }

  static List<TeamItem> _entitiesToTeamItems(
    List<TeamEntity> entities,
    NumberFormat priceFormat,
    String uid,
  ) {
    return entities.map((entity) {
      return TeamItem(
        id: entity.id,
        name: entity.name,
        memberCount: entity.members.length,
      );
    }).toList();
  }

  static Observable<TeamListState> _getTeamList(
    UserBloc userBloc,
    FirestoreTeamRepository teamRepository,
    NumberFormat priceFormat,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        teamRepository,
        priceFormat,
      );
    });
  }

  static Stream<TeamAddedMessage> _getAddedMessage(
    String newTeamName,
    UserBloc userBloc,
    FirestoreTeamRepository teamRepository,
  ) async* {
    LoginState loginState = userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      try {
        await teamRepository.addTeam(
          userId: loginState.uid,
          newTeamName: newTeamName,
        );
        yield TeamAddedMessageSuccess(newTeamName);
      } catch (e) {
        yield TeamAddedMessageError(e);
      }
    } else {
      yield TeamAddedMessageError(NotLoggedInError());
    }
  }
}