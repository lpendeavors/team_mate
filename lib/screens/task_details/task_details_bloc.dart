import 'dart:async';

import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/task/firestore_task_repository.dart';
import 'package:team_mate/models/task_entity.dart';
import 'package:team_mate/screens/task_details/task_details_state.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

const _kInitialTaskDetailState = TaskDetailsState(
  error: null,
  isLoading: true,
  taskDetails: null,
);

class TaskDetailsBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  Function(String) reassignTask;
  Function(DateTime) completeTask;

  ///
  /// Output streams
  ///
  final ValueObservable<TaskDetailsState> taskDetailsState$;
  final Stream<TaskDetailMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  TaskDetailsBloc._({
    @required this.reassignTask,
    @required this.completeTask,
    @required this.taskDetailsState$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  factory TaskDetailsBloc({
    @required UserBloc userBloc,
    @required FirestoreTaskRepository taskRepository,
    @required NumberFormat priceFormat,
    @required String taskId,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(taskRepository != null, 'taskRepository cannot be null');
    assert(priceFormat != null, 'priceFormat cannot be null');
    assert(taskId != null, 'taskId cannot be null');

    ///
    /// Stream controllers
    ///
    final reassignTask = PublishSubject<String>(sync: true);
    final completeTask = PublishSubject<DateTime>(sync: true);

    ///
    /// Streams
    ///
    final message$ = _getTaskDetailMessage(
      reassignTask,
      completeTask,
      userBloc,
      taskRepository,
    );

    final taskDetailState$ = Observable(
      _getTaskDetails(
        userBloc,
        taskRepository,
        priceFormat,
        taskId,
      )
    ).publishValueSeeded(_kInitialTaskDetailState);

    final subscriptions = <StreamSubscription>[
      taskDetailState$.connect(),
      message$.connect(),
    ];

    return TaskDetailsBloc._(
      reassignTask: (userId) => reassignTask.add(userId),
      completeTask: (dateTime) => completeTask.add(dateTime),
      taskDetailsState$: taskDetailState$,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
      }
    );
  }

  @override void dispose() => _dispose;

  static Observable<TaskDetailsState> _toState(
    LoginState loginState,
    FirestoreTaskRepository taskRepository,
    NumberFormat priceFormat,
    String taskId,
  ) {
    if (loginState is Unauthenticated) {
      return Observable.just(
        _kInitialTaskDetailState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      return Observable(
        taskRepository.getById(taskId: taskId)
        .map((task) {
          return _kInitialTaskDetailState.copyWith(
            taskDetails: _taskDetailEntityToItem(task),
            isLoading: false,
          );
        }),
      )
      .startWith(_kInitialTaskDetailState)
      .onErrorReturnWith((e) {
        return _kInitialTaskDetailState.copyWith(
          error: e,
          isLoading: false,
        );
      });
    }

    return Observable.just(
      _kInitialTaskDetailState.copyWith(
        error: "Dont know the loginState=$loginState",
        isLoading: false,
      ),
    );
  }

  static TaskDetailItem _taskDetailEntityToItem(
    TaskEntity entity
  ) {
    return TaskDetailItem(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate.toDate(),
      assignee: entity.assignedTo,
    );
  }

  static Observable<TaskDetailsState> _getTaskDetails(
    UserBloc userBloc,
    FirestoreTaskRepository taskRepository,
    NumberFormat priceFormat,
    String taskId,
  ) {
    return userBloc.loginState$.switchMap((loginState) {
      return _toState(
        loginState,
        taskRepository,
        priceFormat,
        taskId,
      );
    });
  }

  static ConnectableObservable<TaskDetailMessage> _getTaskDetailMessage(
    Observable<String> reassignTask,
    Observable<DateTime> completeTask,
    UserBloc userBloc,
    FirestoreTaskRepository taskRepository,
  ) {
    return Observable.combineLatest([reassignTask, completeTask], (message) {

    }).publish();
  }
}