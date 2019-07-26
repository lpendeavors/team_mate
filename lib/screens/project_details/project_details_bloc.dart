import 'dart:async';

import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/project/firestore_project_repository.dart';
import 'package:team_mate/data/task/firestore_task_repository.dart';
import 'package:team_mate/models/task_entity.dart';
import 'package:team_mate/models/project_entity.dart';
import 'package:team_mate/screens/project_details/project_details_state.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialProjectDetailState = ProjectDetailsState(
  error: null,
  isLoading: true,
  projectDetails: null,
  taskItems: <TaskItem>[],
);

class ProjectDetailsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  Function() addNewTask;

  ///
  /// Output streams
  ///
  final ValueObservable<ProjectDetailsState> projectDetailsState$;
  final Stream<ProjectDetailMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  ProjectDetailsBloc._({
    @required this.addNewTask,
    @required this.projectDetailsState$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory ProjectDetailsBloc({
    @required UserBloc userBloc,
    @required FirestoreProjectRepository projectRepository,
    @required FirestoreTaskRepository taskRepository,
    @required NumberFormat priceFormat,
    @required String projectId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(projectRepository != null, 'projectRepository cannot be null');
    assert(taskRepository != null, 'taskRepository cannot be null');
    assert(priceFormat != null, 'priceFormat cannot be null');
    assert(projectId != null, 'projectId cannot be null');

    ///
    /// Stream controllers
    ///
    final addNewTask = PublishSubject<String>(sync: true);

    ///
    /// Streams
    ///
    final message$ = _getProjectDetailMessage(
      addNewTask,
      userBloc,
      taskRepository,
    );

    final projectDetailState$ = Observable.combineLatest2<ProjectDetailsState,
      ProjectDetailMessage, ProjectDetailsState>(
      _getProjectDetails(
        userBloc,
        projectRepository,
        taskRepository,
        priceFormat,
        projectId,
      ),
      message$
        .where((message) => message is ProjectTaskAddedMessageError)
        .startWith(null),
      (details, error) {
        print('[DEBUG] emit latest state when error occurred $error tasks=${details.taskItems.length}');
        return details;
      },
    ).publishValueSeeded(_kInitialProjectDetailState);

    final subscriptions = <StreamSubscription>[
      projectDetailState$.connect(),
      message$.connect(),
    ];

    return ProjectDetailsBloc._(
      addNewTask: () => addNewTask.add(null),
      projectDetailsState$: projectDetailState$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override void dispose() => _dispose();

  static Observable<ProjectDetailsState> _toState(
    LoginState loginState,
    FirestoreProjectRepository projectRepository,
    FirestoreTaskRepository taskRepository,
    NumberFormat priceFormat,
    String projectId,
  ) {
    if (loginState is Unauthenticated) {
      return Observable.just(
        _kInitialProjectDetailState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Observable.zip2(
        projectRepository.getById(uid: projectId),
        taskRepository.tasksByProject(projectId: projectId),
        (project, tasks) {
          return _kInitialProjectDetailState.copyWith(
            projectDetails: _projectDetailEntityToItem(project),
            taskItems: _taskEntitiesToTaskItems(tasks, priceFormat),
            isLoading: false,
          );
        }
      )
      .startWith(_kInitialProjectDetailState)
      .onErrorReturnWith((e) {
        return _kInitialProjectDetailState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Observable.just(
      _kInitialProjectDetailState.copyWith(
        error: "Dont know the loginState=$loginState",
        isLoading: false,
      ),
    );
  }

  static ProjectDetailItem _projectDetailEntityToItem(
    ProjectEntity entity
  ) {
    return ProjectDetailItem(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      dueDate: entity.dueDate.toDate(),
    );
  }

  static List<TaskItem> _taskEntitiesToTaskItems(
    List<TaskEntity> entities,
    NumberFormat priceFormat,
  ) {
    return entities.map((entity) {
      return TaskItem(
        id: entity.id,
        name: entity.title,
        dueDate: entity.dueDate.toDate(),
      );
    }).toList();
  }

  static Observable<ProjectDetailsState> _getProjectDetails(
    UserBloc userBloc,
    FirestoreProjectRepository projectRepository,
    FirestoreTaskRepository taskRepository,
    NumberFormat priceFormat,
    String projectId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        projectRepository,
        taskRepository,
        priceFormat,
        projectId,
      );
    });
  }

  static ConnectableObservable<ProjectDetailMessage> _getProjectDetailMessage(
    Observable<String> addNewTask,
    UserBloc userBloc,
    FirestoreTaskRepository taskRepository,
  ) {
    return Observable.combineLatest([addNewTask], (message) {

    }).publish();
  }
}