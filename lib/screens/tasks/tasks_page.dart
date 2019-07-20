import 'dart:async';

import 'package:team_mate/widgets/root_scaffold.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/screens/tasks/tasks_bloc.dart';
import 'package:team_mate/screens/tasks/tasks_state.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class TasksPage extends StatefulWidget {
  final TasksBloc tasksBloc;

  const TasksPage({
    Key key,
    @required this.tasksBloc,
  }) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  StreamSubscription _subscription;
  TasksBloc tasksBloc;

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        final s = S.of(context);

        return AlertDialog(
          title: Text(s.exit_app),
          content: Text(s.sure_want_to_exit_app),
          actions: <Widget>[
            FlatButton(
              child: Text(s.no),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(s.exit),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    tasksBloc = widget.tasksBloc;
    //_subscription = tasksBloc.message$.listen(_showMessage);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            S.of(context).tasks_page_title,
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => RootScaffold.openDrawer(context),
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        body: SingleChildScrollView(

        ),
      ),
    );
  }

  _showMessage(TasksMessage message) {

  }
}