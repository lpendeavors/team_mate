import 'dart:async';

import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/screens/task_details/task_details_bloc.dart';
import 'package:team_mate/screens/task_details/task_details_state.dart';
import 'package:flutter/material.dart';

enum TaskActions { reassignTask, completeTask }

class TaskDetailsPage extends StatefulWidget {
  final UserBloc userBloc;
  final TaskDetailsBloc Function() initTaskDetailsBloc;

  const TaskDetailsPage({
    Key key,
    @required this.userBloc,
    @required this.initTaskDetailsBloc,
  }) : super(key: key);

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> with SingleTickerProviderStateMixin {
  TaskDetailsBloc _taskDetailsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _taskDetailsBloc = widget.initTaskDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _taskDetailsBloc.message$.listen(_showMessageResult),
    ];
  }

  @override
  void _showMessageResult(TaskDetailMessage message) {
    print('[DEBUG] task_detail_message=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _taskDetailsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskDetailsState>(
      stream: _taskDetailsBloc.taskDetailsState$,
      initialData: _taskDetailsBloc.taskDetailsState$.value,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Task Details',
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(false),
              color: Theme.of(context).primaryColorDark,
            ),
            actions: <Widget>[
              PopupMenuButton<TaskActions>(
                icon: Icon(Icons.settings, color: Theme.of(context).primaryColorDark),
                onSelected: (TaskActions result) {
                  switch (result) {
                    case TaskActions.completeTask:
                      print('complete');
                      break;
                    case TaskActions.reassignTask:
                      print('reassign');
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: TaskActions.completeTask,
                    child: Text(
                      'Complete Task',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: TaskActions.reassignTask,
                    child: Text(
                      'Reassign Task',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              constraints: BoxConstraints.expand(),
              color: Theme.of(context).backgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        snapshot.data.taskDetails != null ? snapshot.data.taskDetails.title : '',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 28.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        snapshot.data.taskDetails != null ? snapshot.data.taskDetails.description : '',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'DUE: ',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          Text(
                            snapshot.data.taskDetails != null ? snapshot.data.taskDetails.dueDate.toString() : '',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'ASSIGNED TO: ',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          Text(
                            snapshot.data.taskDetails != null ? snapshot.data.taskDetails.assignee : '',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}