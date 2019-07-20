import 'dart:async';

import 'package:collection/collection.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/task/firestore_task_repository.dart';
import 'package:team_mate/models/task_entity.dart';
import 'package:team_mate/screens/tasks/tasks_state.dart';
import 'package:team_mate/shared_pref_util.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

const _kTasksByUserInitial = <TaskItem>[];

class TasksBloc implements BaseBloc {
  ///
  /// Input functions
  ///

  ///
  /// Output streams
  ///
  final Observable<List<TaskItem>> tasksByUser$;
  final Stream<TasksMessage> message$;

  ///
  /// Clean up resource
  ///
  final void Function() _dispose;

  TasksBloc._({
    @required this.message$,
    @required this.tasksByUser$,
    @required Function() dispose,
  }) : this._dispose = dispose;

  factory TasksBloc({
    @required UserBloc userBloc,
    @required FirestoreTaskRepository taskRepository,
    @required SharedPrefUtil sharedPrefUtil,
    @required NumberFormat priceFormat,
  }) {
    ///
    /// Assert
    ///
    assert(userBloc != null, 'userBloc cannot be null');
    assert(taskRepository != null, 'taskRepository cannot be null');
    assert(sharedPrefUtil != null, 'sharedPrefUtil cannot be null');
    assert(priceFormat != null, 'priceFormat cannot be null');

    ///
    /// Controllers
    ///
    // ignore: close_sinks
    final tasksByUserController = BehaviorSubject.seeded(_kTasksByUserInitial);

    ///
    /// Streams
    ///
    final Observable<List<TaskItem>> tasksByUser$ = _getTasksByUser(
      userBloc.loginState$.value,
      taskRepository,
      userBloc,
      priceFormat,
    );

//    final ConnectableObservable<TasksMessage> message$ = Observable.merge(
//      <Stream<TasksMessage>>[
//        _getTaskCompletedMessage(
//
//      ],
//    ).publish();

    ///
    /// Subscriptions
    ///
    final subscriptions = <StreamSubscription<dynamic>>[
      /// Listen
      tasksByUser$.listen(tasksByUserController.add),
      /// Connect
      //message$.connect(),
    ];

    ///
    /// Return
    ///
    return TasksBloc._(
      tasksByUser$: tasksByUser$,
      //message$: message$,
      dispose: () {
        subscriptions.forEach((subscription) => subscription.cancel());
      }
    );
  }

  static Observable<List<TaskItem>> _getTasksByUser(
    LoginState loginState,
    FirestoreTaskRepository taskRepository,
    UserBloc userBloc,
    NumberFormat priceFormat,
  ) {
    final userId = loginState is LoggedInUser ? loginState.uid : null;
    if (userId == null) {
      return Observable.error("User must be logged in");
    }
    return Observable.combineLatest2(
      taskRepository.tasksByUser(
        userId: userId,
      ),
      userBloc.loginState$,
      (List<TaskEntity> entities, LoginState loginState) =>
        TasksBloc._toTaskItems(
          entities,
          loginState,
          priceFormat,
        ),
    ).startWith(_kTasksByUserInitial);
  }

  static List<TaskItem> _toTaskItems(
    List<TaskEntity> taskEntities,
    LoginState loginState,
    NumberFormat priceFormat,
  ) {
    return taskEntities.map((taskEntity) {
      CompletedIconState completedState;
      if (taskEntity.complete) {
        completedState = CompletedIconState.showComplete;
      } else {
        completedState = CompletedIconState.showNotComplete;
      }

      return TaskItem(
        id: taskEntity.id,
        title: taskEntity.title,
        description: taskEntity.description,
        dueDate: taskEntity.dueDate.toDate(),
        completedState: completedState,
      );
    }).toList();
  }

  static Observable<TaskCompletedMessage> _getTaskCompletedMessage(
    Observable<void> completeTask$,
    SharedPrefUtil sharedPrefUtil
  ) {

  }

  @override
  void dispose() {
    if (_dispose != null) {
      _dispose();
    }
  }
}