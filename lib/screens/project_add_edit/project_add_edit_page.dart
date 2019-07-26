import 'dart:async';

import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/screens/project_add_edit/project_add_edit_bloc.dart';
import 'package:team_mate/screens/project_add_edit/project_add_edit_state.dart';
import 'package:team_mate/widgets/tm_datetime_dropdown.dart';
import 'package:team_mate/widgets/tm_input_field.dart';
import 'package:team_mate/widgets/tm_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectAddEditPage extends StatefulWidget {
  final UserBloc userBloc;
  final ProjectAddEditBloc Function() initProjectAddEditBloc;
  
  const ProjectAddEditPage({
    Key key,
    @required this.userBloc,
    @required this.initProjectAddEditBloc,
  }) : super(key: key);
  
  @override
  _ProjectAddEditPageState createState() => _ProjectAddEditPageState();
}

class _ProjectAddEditPageState extends State<ProjectAddEditPage> with SingleTickerProviderStateMixin {
  ProjectAddEditBloc _projectAddEditBloc;
  List<StreamSubscription> _subscriptions;

  final _projectNameFocusNode = FocusNode();
  final _projectDescriptionFocusNode = FocusNode();
  final _projectDueDateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _projectAddEditBloc = widget.initProjectAddEditBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _projectAddEditBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(ProjectMessage message) {
    print('[DEBUG] project_add_edit_message=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _projectAddEditBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: StreamBuilder<ProjectDetailsState>(
        stream: _projectAddEditBloc.projectDetailsState$,
        initialData: _projectAddEditBloc.projectDetailsState$.value,
        builder: (context, snapshot) {
          var data = snapshot.data;
          var selectedDate = DateTime.now();

          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(
                data.projectDetails == null ? s.new_project : s.edit_project,
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
            ),
            body: Container(
              color: Theme.of(context).backgroundColor,
              constraints: BoxConstraints.expand(),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    child: SingleChildScrollView(
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: TeamMateInputField(
                                hintText: s.project_name,
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                selfFocusNode: _projectNameFocusNode,
                                nextFocusNode: _projectDescriptionFocusNode,
                                changedCallback: _projectAddEditBloc.projectNameChanged,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: TeamMateInputField(
                                hintText: s.project_description,
                                maxLines: 3,
                                inputType: TextInputType.multiline,
                                inputAction: TextInputAction.next,
                                selfFocusNode: _projectDescriptionFocusNode,
                                nextFocusNode: _projectDueDateFocusNode,
                                changedCallback: _projectAddEditBloc.projectDescriptionChanged,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                s.project_due_date,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: TeamMateDateTimeDropdown(
                                selectedDate: selectedDate,
                                selectDate: _projectAddEditBloc.projectDateChanged,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 32.0),
                              child: TeamMateButton(
                                label: s.save_project,
                                pressedCallback: () {
                                  _projectAddEditBloc.saveProject();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_projectAddEditBloc.isLoading$.value) {
      final s = S.of(context);
      final exitProjectAddEdit = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(s.exit_project_add_edit),
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
        }
      );
      return exitProjectAddEdit ?? false;
    }
    return true;
  }
}