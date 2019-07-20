import 'package:team_mate/data/user/firebase_user_repository.dart';
import 'package:team_mate/data/task/firestore_task_repository.dart';
import 'package:team_mate/data/team/firestore_team_repository.dart';
import 'package:team_mate/data/project/firestore_project_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

class Injector extends InheritedWidget {
  final FirebaseUserRepository userRepository;
  final FirestoreTaskRepository taskRepository;
  final FirestoreTeamRepository teamRepository;
  final FirestoreProjectRepository projectRepository;
  final NumberFormat priceFormat;

  Injector({
    Key key,
    @required this.userRepository,
    @required this.taskRepository,
    @required this.teamRepository,
    @required this.projectRepository,
    @required this.priceFormat,
    @required Widget child,
  }) : super(key: key, child: child);

  static Injector of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(Injector);

  @override
  bool updateShouldNotify(Injector oldWidget) =>
      userRepository != oldWidget.userRepository &&
      taskRepository != oldWidget.taskRepository &&
      teamRepository != oldWidget.teamRepository &&
      projectRepository != oldWidget.projectRepository &&
      priceFormat != oldWidget.priceFormat;
}