import 'dart:async';

import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/screens/project_details/project_details_bloc.dart';
import 'package:team_mate/screens/project_details/project_details_state.dart';
import 'package:flutter/material.dart';

enum ProjectActions { addTask }

class ProjectDetailsPage extends StatefulWidget {
  final UserBloc userBloc;
  final ProjectDetailsBloc Function() initProjectDetailsBloc;

  const ProjectDetailsPage({
    Key key,
    @required this.userBloc,
    @required this.initProjectDetailsBloc,
  }) : super(key: key);

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> with SingleTickerProviderStateMixin {
  ProjectDetailsBloc _projectDetailsBloc;
  List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();

    _projectDetailsBloc = widget.initProjectDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _projectDetailsBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(ProjectDetailMessage message) {
    print('[DEBUG] project_detail_message=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _projectDetailsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProjectDetailsState>(
      stream: _projectDetailsBloc.projectDetailsState$,
      initialData: _projectDetailsBloc.projectDetailsState$.value,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Project Details',
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
              PopupMenuButton<ProjectActions>(
                icon: Icon(Icons.settings, color: Theme.of(context).primaryColorDark),
                onSelected: (ProjectActions result) {
                  switch (result) {
                    case ProjectActions.addTask:
                      Navigator.of(context).pushNamed(
                        '/task_add_edit',
                        arguments: <String, String>{
                          'projectId': _projectDetailsBloc.projectDetailsState$.value.projectDetails.id,
                          'taskId': null,
                        }
                      );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: ProjectActions.addTask,
                    child: Text(
                      'New Task',
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
                      padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                      child: Text(
                        snapshot.data.projectDetails != null ? snapshot.data.projectDetails.name : '',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 28.0
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        snapshot.data.projectDetails != null ? snapshot.data.projectDetails.description : '',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
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
                            snapshot.data.projectDetails != null ? snapshot.data.projectDetails.dueDate.toString() : '',
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
                      child: Text(
                        'TASKS: ',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
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