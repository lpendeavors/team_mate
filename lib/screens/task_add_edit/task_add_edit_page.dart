import 'dart:async';

import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/screens/task_add_edit/task_add_edit_bloc.dart';
import 'package:team_mate/screens/task_add_edit/task_add_edit_state.dart';
import 'package:team_mate/widgets/tm_datetime_dropdown.dart';
import 'package:team_mate/widgets/tm_input_field.dart';
import 'package:team_mate/widgets/tm_button.dart';
import 'package:flutter/material.dart';


class TaskAddEditPage extends StatefulWidget {
  final UserBloc userBloc;
  final TaskAddEditBloc Function() initTaskAddEditBloc;

  const TaskAddEditPage({
    Key key,
    @required this.userBloc,
    @required this.initTaskAddEditBloc,
  }) : super(key: key);

  @override
  _TaskAddEditPageState createState() => _TaskAddEditPageState();
}

class _TaskAddEditPageState extends State<TaskAddEditPage> with SingleTickerProviderStateMixin {
  TaskAddEditBloc _taskAddEditBloc;
  List<StreamSubscription> _subscriptions;

  final _taskTitleFocusNode = FocusNode();
  final _taskDescriptionFocusNode = FocusNode();
  final _taskDueDateFocusNode = FocusNode();
  final _taskAssigneeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _taskAddEditBloc = widget.initTaskAddEditBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/login'))),
      _taskAddEditBloc.message$.listen(_showMessageResult),
    ];
  }

  void _showMessageResult(TaskMessage message) {
    print('[DEBUG] task_add_edit_message=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _taskAddEditBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: StreamBuilder<TaskDetailsState>(
        stream: _taskAddEditBloc.taskDetailsState$,
        initialData: _taskAddEditBloc.taskDetailsState$.value,
        builder: (context, snapshot) {
          var data = snapshot.data;
          var selectedDate = DateTime.now();

          return Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(
                data.taskDetails == null ? s.new_task : s.edit_task,
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
                                hintText: s.task_title,
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                selfFocusNode: _taskTitleFocusNode,
                                nextFocusNode: _taskDescriptionFocusNode,
                                changedCallback: _taskAddEditBloc.taskNameChanged,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: TeamMateInputField(
                                hintText: s.task_description,
                                maxLines: 3,
                                inputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                selfFocusNode: _taskDescriptionFocusNode,
                                nextFocusNode: _taskDueDateFocusNode,
                                changedCallback: _taskAddEditBloc.taskDescriptionChanged,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'Assign To',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                s.task_due_date,
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
                                selectDate: _taskAddEditBloc.taskDueDateChanged,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 32.0),
                              child: TeamMateButton(
                                label: s.save_task,
                                pressedCallback: () {
                                  _taskAddEditBloc.saveTask();
                                },
                              ),
                            )
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
    if (_taskAddEditBloc.isLoading$.value) {
      final s = S.of(context);
      final exitTaskAddEdit = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(s.exit_task_add_edit),
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
      return exitTaskAddEdit ?? false;
    }
    return true;
  }
}