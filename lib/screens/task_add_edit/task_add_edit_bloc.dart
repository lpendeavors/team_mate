import 'dart:async';

import 'package:intl/intl.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/task/firestore_task_repository.dart';
import 'package:team_mate/models/task_entity.dart';
import 'package:team_mate/screens/task_add_edit/task_add_edit_state.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

bool _isTaskTitleValid(String taskTitle) {
  return taskTitle.length >= 3;
}

bool _isTaskDescriptionValid(String taskDescription) {
  return taskDescription.length >= 6;
}

bool _isTaskDueDateValid(DateTime dueDate) {
  return dueDate.isAfter(DateTime(2019));
}

bool _isTaskAssigneeValid(String userId) {
  return userId.isNotEmpty;
}

const _kInitialTaskDetailsState = TaskDetailsState(
  error: null,
  isLoading: true,
  taskDetails: null,
);

class TaskAddEditBloc implements BaseBloc {
  ///
  /// Input functions
  ///
  final void Function() saveTask;
  final void Function(String) taskNameChanged;
  final void Function(String) taskDescriptionChanged;
  final void Function(DateTime) taskDueDateChanged;
  final void Function(String) taskAssigneeChanged;

  ///
  /// Output streams
  ///
  final ValueObservable<TaskDetailsState> taskDetailsState$;
  final ValueObservable<bool> isLoading$;
  final Stream<TaskTitleError> taskTitleError$;
  final Stream<TaskDescriptionError> taskDescriptionError$;
  final Stream<TaskDueDateError> taskDueDateError$;
  final Stream<TaskAssigneeError> taskAssigneeError$;
  final Stream<TaskMessage> message$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  TaskAddEditBloc._({
    @required this.saveTask,
    @required this.taskNameChanged,
    @required this.taskDescriptionChanged,
    @required this.taskDueDateChanged,
    @required this.taskAssigneeChanged,
    @required this.isLoading$,
    @required this.taskTitleError$,
    @required this.taskDescriptionError$,
    @required this.taskDueDateError$,
    @required this.taskAssigneeError$,
    @required this.taskDetailsState$,
    @required this.message$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose;

  factory TaskAddEditBloc({
    String taskId,
    @required String projectId,
    @required UserBloc userBloc,
    @required FirestoreTaskRepository taskRepository,
    @required NumberFormat priceFormat,
  }) {
    ///
    /// Assert
    ///
    assert(projectId != null , 'projectId cannot be null');
    assert(userBloc != null, 'usreBloc cannot be null');
    assert(taskRepository != null, 'taskRepository cannot be null');
    assert(priceFormat != null, 'priceFormat cannot be null');

    ///
    /// Stream controllers
    ///
    final taskTitleSubject = BehaviorSubject<String>.seeded('');
    final taskDescriptionSubject = BehaviorSubject<String>.seeded('');
    final taskDueDateSubject = BehaviorSubject<DateTime>.seeded(DateTime.now());
    final taskAssigneeSubject = BehaviorSubject<String>.seeded('');
    final saveTaskSubject = PublishSubject<void>();
    final isLoadingSubject = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///
    final taskTitleError$ = taskTitleSubject.map((taskTitle) {
      if (_isTaskTitleValid(taskTitle)) return null;
      return const TaskTitleError();
    }).share();

    final taskDescriptionError$ = taskDescriptionSubject.map((taskDescription) {
      if (_isTaskDescriptionValid(taskDescription)) return null;
      return const TaskDescriptionError();
    }).share();

    final taskDueDateError$ = taskDueDateSubject.map((taskDueDate) {
      if (_isTaskDueDateValid(taskDueDate)) return null;
      return const TaskDueDateError();
    }).share();

    final taskAssigneeError$ = taskAssigneeSubject.map((taskAssignee) {
      if (_isTaskAssigneeValid(taskAssignee)) return null;
      return const TaskAssigneeError();
    }).share();

    final allFieldsAreValid$ = Observable.combineLatest(
      [
        taskTitleError$,
        taskDescriptionError$,
        taskDueDateError$,
        taskAssigneeError$,
      ],
      (allError) => allError.every((error) {
        print(error);
        return error == null;
      }),
    );

    final message$ = saveTaskSubject
      .withLatestFrom(allFieldsAreValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .exhaustMap(
        (_) => performSave(
          taskId ?? null,
          userBloc,
          projectId,
          taskRepository,
          taskTitleSubject.value,
          taskDescriptionSubject.value,
          taskDueDateSubject.value,
          taskAssigneeSubject.value,
          isLoadingSubject,
        )
      ).publish();

    final taskDetailsState$ = Observable<TaskDetailsState>(
      _getTaskDetails(
        userBloc,
        taskRepository,
        priceFormat,
        taskId,
      )
    ).publishValueSeeded(_kInitialTaskDetailsState);

    ///
    /// Controllers and subscriptions
    ///
    final subscriptions = <StreamSubscription>[
      taskDetailsState$.connect(),
      message$.connect(),
    ];

    final controllers = <StreamController>[
      taskTitleSubject,
      taskDescriptionSubject,
      taskDueDateSubject,
      taskAssigneeSubject,
      saveTaskSubject,
      isLoadingSubject,
    ];

    return TaskAddEditBloc._(
      taskNameChanged: taskTitleSubject.add,
      taskDescriptionChanged: taskDescriptionSubject.add,
      taskDueDateChanged: taskDueDateSubject.add,
      taskAssigneeChanged: taskAssigneeSubject.add,
      taskTitleError$: taskTitleError$,
      taskDescriptionError$: taskDescriptionError$,
      taskDueDateError$: taskDueDateError$,
      taskAssigneeError$: taskAssigneeError$,
      taskDetailsState$: taskDetailsState$,
      isLoading$: isLoadingSubject,
      saveTask: () => saveTaskSubject.add(null),
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      }
    );
  }

  static Observable<TaskDetailsState> _toState(
    LoginState loginState,
    FirestoreTaskRepository taskRepository,
    NumberFormat priceFormat,
    String taskId,
  ) {
    if (loginState is Unauthenticated) {
      return Observable.just(
        _kInitialTaskDetailsState.copyWith(
          error: NotLoggedInError(),
          isLoading: false,
        ),
      );
    }

    if (loginState is LoggedInUser) {
      if (taskId != null) {
        return Observable(taskRepository.getById(taskId: taskId))
          .map((entity) {
            return _entityToTaskItem(
              entity,
            );
          })
          .map((taskItem) {
            return _kInitialTaskDetailsState.copyWith(
              taskDetails: taskItem,
              isLoading: false,
            );
          })
          .startWith(_kInitialTaskDetailsState)
          .onErrorReturnWith((e) {
            return _kInitialTaskDetailsState.copyWith(
              error: e,
              isLoading: false,
            );
          });
      } else {
        return Observable.just(
          _kInitialTaskDetailsState.copyWith(
            isLoading: false,
          ),
        );
      }
    }
    return Observable.just(
      _kInitialTaskDetailsState.copyWith(
        error: "Dont know loginState=$loginState",
        isLoading: false,
      ),
    );
  }

  static TaskAddEditItem _entityToTaskItem(
    TaskEntity entity
  ) {
    return TaskAddEditItem(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate.toDate(),
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

  static Stream<TaskMessage> performSave(
    String taskId,
    UserBloc userBloc,
    String projectId,
    FirestoreTaskRepository taskRepository,
    String taskTitle,
    String taskDescription,
    DateTime taskDueDate,
    String taskAssignee,
    Sink<bool> isLoadingSink,
  ) async* {
    print('[DEBUG] saveTask');
    LoginState loginState = userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      try {
        await taskRepository.saveTask(
          taskId,
          taskTitle,
          taskDescription,
          taskDueDate,
          taskAssignee,
          loginState.uid,
          projectId,
        );
        yield TaskAddedMessageSuccess(taskTitle);
      } catch (e) {
        yield TaskAddedMessageError(e);
      }
    } else {
      yield TaskAddedMessageError(NotLoggedInError());
    }
  }
}