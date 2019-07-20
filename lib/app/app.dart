import 'dart:async';

import 'package:team_mate/app/app_locale_bloc.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/dependency_injection.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_navigation_drawer.dart';
import 'package:team_mate/screens/tasks/tasks_bloc.dart';
import 'package:team_mate/screens/tasks/tasks_page.dart';
import 'package:team_mate/screens/tasks/tasks_state.dart';
import 'package:team_mate/screens/teams/teams_bloc.dart';
import 'package:team_mate/screens/teams/teams_page.dart';
import 'package:team_mate/screens/teams/teams_state.dart';
import 'package:team_mate/screens/team_details/team_details_bloc.dart';
import 'package:team_mate/screens/team_details/team_details_page.dart';
import 'package:team_mate/screens/team_details/team_details_state.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_bloc.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_page.dart';
import 'package:team_mate/screens/login/login_page.dart';
import 'package:team_mate/screens/register/register_page.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class MyApp extends StatelessWidget {
  final appTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'KoHo',
    primaryColorDark: const Color(0xff042F40),
    primaryColorLight: const Color(0xff1FAFBF),
    primaryColor: const Color(0xff595959),
    accentColor: const Color(0xffF24150),
    backgroundColor: const Color(0xffF2F2F2),
    buttonColor: const Color(0xff042F40),
    canvasColor: const Color(0xff042F40),
  );

  final appRoutes = <String, WidgetBuilder>{
    '/': (context) {
      return TasksPage(
        tasksBloc: BlocProvider.of<TasksBloc>(context),
      );
    },
    '/teams': (context) {
      return TeamsPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        initTeamsBloc: () {
          return TeamsBloc(
            userBloc: BlocProvider.of<UserBloc>(context),
            teamRepository: Injector.of(context).teamRepository,
            priceFormat: Injector.of(context).priceFormat,
          );
        },
      );
    },
    '/login': (context) {
      return LoginPage(
        userBloc: BlocProvider.of<UserBloc>(context),
        userRepository: Injector.of(context).userRepository,
      );
    },
    '/forgot_password': (context) {
      return BlocProvider<ForgotPasswordBloc>(
        child: const ForgotPasswordPage(),
        bloc: ForgotPasswordBloc(
          Injector.of(context).userRepository,
        ),
      );
    },
  };

  final RouteFactory onGenerateRoute = (routerSettings) {
    if (routerSettings.name == '/team_details') {
      return MaterialPageRoute(
        builder: (context) {
          return TeamDetailsPage(
            userBloc: BlocProvider.of<UserBloc>(context),
            initTeamDetailsBloc: () {
              return TeamDetailsBloc(
                userBloc: BlocProvider.of<UserBloc>(context),
                teamRepository: Injector.of(context).teamRepository,
                userRepository: Injector.of(context).userRepository,
                projectRepository: Injector.of(context).projectRepository,
                priceFormat: Injector.of(context).priceFormat,
                teamId: routerSettings.arguments as String,
              );
            },
          );
        },
        settings: routerSettings,
      );
    }
  };

  @override
  Widget build(BuildContext context) {
    final localeBloc = BlocProvider.of<LocaleBloc>(context);

    return StreamBuilder<Locale>(
      stream: localeBloc.locale$,
      initialData: localeBloc.locale$.value,
      builder: (context, snapshot) {
        print('[APP_LOCALE] locale = ${snapshot.data}');

        if (!snapshot.hasData) {
          return Container(
            width: double.infinity,
            height: double.infinity,
          );
        }

        return MaterialApp(
          locale: snapshot.data,
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: [
            S.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          localeResolutionCallback: S.delegate.resolution(fallback: const Locale('en', '')),
          onGenerateTitle: (context) => S.of(context).app_title,
          theme: appTheme,
          builder: (BuildContext context, Widget child) {
            print('[DEBUG] App builder');
            return Scaffold(
              drawer: TeamMateDrawer(
                navigator: child.key as GlobalKey<NavigatorState>,
              ),
              body: BodyChild(
                child: child,
                userBloc: BlocProvider.of<UserBloc>(context),
              ),
            );
          },
          initialRoute: '/login',
          routes: appRoutes,
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}

class BodyChild extends StatefulWidget {
  final Widget child;
  final UserBloc userBloc;

  const BodyChild({
    @required this.child,
    @required this.userBloc,
    Key key,
  }) : super(key: key);

  @override
  _BodyChildState createState() => _BodyChildState();
}

class _BodyChildState extends State<BodyChild> {
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    print('[DEBUG] _BodyChildState initState');

    _subscription = widget.userBloc.message$.listen((message) {
      var s = S.of(context);
      if (message is UserLogoutMessage) {
        if (message is UserLogoutMessageSuccess) {
          _showSnackBar(s.logout_success);
        }
        if (message is UserLogoutMessageError) {
          print('[DEBUG] logout error=${message.error}');
          _showSnackBar(s.logout_error);
        }
      }
    });
  }

  @override
  void dispose() {
    print('[DEBUG] _BodyChildState dispose');
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] _BodyChildState build');
    return widget.child;
  }

  void _showSnackBar(String message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}