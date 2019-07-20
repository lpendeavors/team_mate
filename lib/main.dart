import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/app/app.dart';
import 'package:team_mate/app/app_locale_bloc.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/user/firebase_user_repository_imp.dart';
import 'package:team_mate/data/task/firestore_task_repository_impl.dart';
import 'package:team_mate/data/team/firestore_team_repository_impl.dart';
import 'package:team_mate/data/project/firestore_project_repository_impl.dart';
import 'package:team_mate/dependency_injection.dart';
import 'package:team_mate/shared_pref_util.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/screens/tasks/tasks_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  final firestore = Firestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  ///
  /// Setup firestore
  ///
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  ///
  /// Price formatter for USD
  ///
  final priceFormat = NumberFormat.currency(locale: 'en_EN');

  final userRepository = FirebaseUserRepositoryImpl(
    firebaseAuth,
    firestore,
    googleSignIn,
  );
  final taskRepository = FirestoreTaskRepositoryImpl(firestore);
  final teamRepository = FirestoreTeamRepositoryImpl(firestore);
  final projectRepository = FirestoreProjectRepositoryImpl(firestore);

  final sharedPrefUtil = SharedPrefUtil.instance;

  final userBloc = UserBloc(userRepository);
  final taskBloc = TasksBloc(
    sharedPrefUtil: sharedPrefUtil,
    userBloc: userBloc,
    taskRepository: taskRepository,
    priceFormat: priceFormat,
  );

  runApp(
    Injector(
      userRepository: userRepository,
      taskRepository: taskRepository,
      teamRepository: teamRepository,
      projectRepository: projectRepository,
      priceFormat: priceFormat,
      child: BlocProvider<UserBloc>(
        bloc: userBloc,
        child: BlocProvider<TasksBloc>(
          bloc: taskBloc,
          child: BlocProvider<LocaleBloc>(
            bloc: LocaleBloc(sharedPrefUtil),
            child: MyApp(),
          ),
        ),
      ),
    ),
  );
}