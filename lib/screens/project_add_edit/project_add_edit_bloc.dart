import 'dart:async';

import 'package:intl/intl.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/project/firestore_project_repository.dart';
import 'package:team_mate/models/project_entity.dart';
import 'package:team_mate/screens/project_add_edit/project_add_edit_state.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';

bool _isProjectNameValid(String projectName) {
  return projectName.length >= 3;
}

bool _isProjectDescriptionValid(String projectDescription) {
  return projectDescription.length >= 6;
}

bool _isProjectDueDateValid(DateTime dueDate) {
  return dueDate.isAfter(DateTime(2019));
}

const _kInitialProjectDetailsState = ProjectDetailsState(
  error: null,
  isLoading: true,
  projectDetails: null,
);

class ProjectAddEditBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() saveProject;
  final void Function(String) projectNameChanged;
  final void Function(String) projectDescriptionChanged;
  final void Function(DateTime) projectDateChanged;

  ///
  /// Output streams
  ///
  final ValueObservable<ProjectDetailsState> projectDetailsState$;
  final ValueObservable<bool> isLoading$;
  final Stream<ProjectNameError> projectNameError$;
  final Stream<ProjectDescriptionError> projectDescriptionError$;
  final Stream<ProjectDueDateError> projectDueDateError$;
  final Stream<ProjectMessage> message$;

  ///
  /// Clean up resource
  ///
  final void Function() _dispose;

  ProjectAddEditBloc._({
    @required this.saveProject,
    @required this.projectDateChanged,
    @required this.projectDescriptionChanged,
    @required this.projectNameChanged,
    @required this.isLoading$,
    @required this.projectNameError$,
    @required this.projectDescriptionError$,
    @required this.projectDueDateError$,
    @required this.projectDetailsState$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory ProjectAddEditBloc({
    String projectId,
    @required String teamId,
    @required UserBloc userBloc,
    @required FirestoreProjectRepository projectRepository,
    @required NumberFormat priceFormat,
  }) {
    ///
    /// Assert
    ///
    assert(teamId != null, 'teamId cannot be null');
    assert(userBloc != null, 'userBloc cannot be null');
    assert(projectRepository != null, 'projectRepository cannot be null');
    assert(priceFormat != null, 'priceFormat cannot be null');

    ///
    /// Stream controllers
    ///

    final projectNameSubject = BehaviorSubject<String>.seeded('');
    final projectDescriptionSubject = BehaviorSubject<String>.seeded('');
    final projectDueDateSubject = BehaviorSubject<DateTime>.seeded(DateTime.now());
    final saveProjectSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final projectNameError$ = projectNameSubject.map((projectName) {
      if (_isProjectNameValid(projectName)) return null;
      return const ProjectNameError();
    }).share();

    final projectDescriptionError$ = projectDescriptionSubject.map((projectDescription) {
      if (_isProjectDescriptionValid(projectDescription)) return null;
      return const ProjectDescriptionError();
    }).share();

    final projectDueDateError$ = projectDueDateSubject.map((projectDueDate) {
      if (_isProjectDueDateValid(projectDueDate)) return null;
      return const ProjectDueDateError();
    }).share();

    final allFieldsAreValid$ = Observable.combineLatest(
      [
        projectNameError$,
        projectDescriptionError$,
        projectDueDateError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final message$ = saveProjectSubject
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => performSave(
            projectId ?? null,
            userBloc,
            teamId,
            projectRepository,
            projectNameSubject.value,
            projectDescriptionSubject.value,
            projectDueDateSubject.value,
            isLoadingSubject,
          )
      ).publish();

    final projectDetailsState$ = Observable<ProjectDetailsState>(
      _getProjectDetails(
        userBloc,
        projectRepository,
        priceFormat,
        projectId,
      )
    ).publishValueSeeded(_kInitialProjectDetailsState);

    ///
    /// Controller and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      projectDetailsState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      projectNameSubject,
      projectDescriptionSubject,
      projectDueDateSubject,
      saveProjectSubject,
      isLoadingSubject,
    ];

    return ProjectAddEditBloc._(
      projectNameChanged: projectNameSubject.add,
      projectDescriptionChanged: projectDescriptionSubject.add,
      projectDateChanged: projectDueDateSubject.add,
      projectNameError$: projectNameError$,
      projectDescriptionError$: projectDescriptionError$,
      projectDueDateError$: projectDueDateError$,
      projectDetailsState$: projectDetailsState$,
      isLoading$: isLoadingSubject,
      saveProject: () => saveProjectSubject.add(null),
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  static Observable<ProjectDetailsState> _toState(
    LoginState loginState,
    FirestoreProjectRepository projectRepository,
    NumberFormat priceFormat,
    String projectId,
  ) {
    if (loginState is Unauthenticated) {
      return Observable.just(
        _kInitialProjectDetailsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      if (projectId != null) {
        return Observable(projectRepository.getById(uid: projectId))
          .map((entity) {
            return _entityToProjectItem(
              entity,
            );
          })
          .map((projectItem) {
            return _kInitialProjectDetailsState.copyWith(
              projectDetails: projectItem,
              isLoading: false,
            );
          })
          .startWith(_kInitialProjectDetailsState)
          .onErrorReturnWith((e) {
            return _kInitialProjectDetailsState.copyWith(
              error: e,
              isLoading: false,
            );
          });
      } else {
        return Observable.just(
          _kInitialProjectDetailsState.copyWith(
            isLoading: false,
          ),
        );
      }
    }
    return Observable.just(
      _kInitialProjectDetailsState.copyWith(
        error: "Don't know loginState=$loginState",
        isLoading: false,
      ),
    );
  }

  static ProjectAddEditItem _entityToProjectItem(
    ProjectEntity entity
  ) {
    return ProjectAddEditItem(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      dueDate: entity.dueDate.toDate(),
    );
  }

  static Observable<ProjectDetailsState> _getProjectDetails(
    UserBloc userBloc,
    FirestoreProjectRepository projectRepository,
    NumberFormat priceFormat,
    String projectId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        projectRepository,
        priceFormat,
        projectId,
      );
    });
  }

  static Stream<ProjectMessage> performSave(
    String projectId,
    UserBloc userBloc,
    String teamId,
    FirestoreProjectRepository projectRepository,
    String projectName,
    String projectDescription,
    DateTime projectDueDate,
    Sink<bool> isLoadingSink,
  ) async* {
    print('[DEBUG] saveProject');
    LoginState loginState = userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      try {
        await projectRepository.saveProject(
          projectId,
          projectName,
          projectDescription,
          projectDueDate,
          loginState.uid,
          teamId,
        );
        yield ProjectAddedMessageSuccess(projectName);
      } catch (e) {
        yield ProjectAddedMessageError(e);
      }
    } else {
      yield ProjectAddedMessageError(NotLoggedInError());
    }
  }
}