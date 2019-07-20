import 'dart:async';

import 'package:team_mate/app/app.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/user/firebase_user_repository.dart';
import 'package:team_mate/dependency_injection.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/screens/login/widgets/email_text_field.dart';
import 'package:team_mate/screens/login/widgets/password_text_field.dart';
import 'package:team_mate/screens/login/widgets/login_button.dart';
import 'package:team_mate/screens/login/widgets/google_sign_in_button.dart';
import 'package:team_mate/screens/login/email_login_bloc.dart';
import 'package:team_mate/screens/login/google_sign_in_bloc.dart';
import 'package:team_mate/screens/login/login_state.dart';
import 'package:team_mate/screens/register/register_bloc.dart';
import 'package:team_mate/screens/register/register_page.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_bloc.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_page.dart';
import 'package:team_mate/widgets/loading_indicator.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class LoginPage extends StatefulWidget {
  final FirebaseUserRepository userRepository;

  final UserBloc userBloc;

  const LoginPage({
    Key key,
    @required this.userRepository,
    @required this.userBloc,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  EmailLoginBloc _emailLoginBloc;
  GoogleSignInBloc _googleSignInBloc;
  List<StreamSubscription> _subscriptions;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    var loginState = widget.userBloc.loginState$.value;
    if (loginState is LoggedInUser) {
      Navigator.of(context).pushNamed('/');
    }

    _emailLoginBloc = EmailLoginBloc(widget.userRepository);
    _googleSignInBloc = GoogleSignInBloc(widget.userRepository);

    _subscriptions = [
      Observable.merge([
        _emailLoginBloc.message$,
        _googleSignInBloc.message$,
        widget.userBloc.loginState$
          .where((state) => state is LoggedInUser)
        .map((_) => const LoginMessageSuccess()),
      ]).listen(_showLoginMessage),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          child: Container(
            color: Theme.of(context).backgroundColor,
            constraints: BoxConstraints.expand(),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SingleChildScrollView(
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 117.0, bottom: 47.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  S.of(context).app_title,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  S.of(context).login_subtitle,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: EmailTextField(
                              emailFocusNode: _emailFocusNode,
                              passwordFocusNode: _passwordFocusNode,
                              emailLoginBloc: _emailLoginBloc,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: PasswordTextField(
                              focusNode: _passwordFocusNode,
                              emailLoginBloc: _emailLoginBloc,
                            ),
                          ),
                          StreamBuilder<bool>(
                            stream: _emailLoginBloc.isLoading$,
                            initialData: _emailLoginBloc.isLoading$.value,
                            builder: (context, snapshot) {
                              return LoadingIndicator(
                                isLoading: snapshot.data,
                                key: ValueKey(snapshot.data),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  child: Text(
                                    s.forgot_password,
                                    style: TextStyle(color: Theme.of(context).accentColor),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BlocProvider<ForgotPasswordBloc>(
                                            child: const ForgotPasswordPage(),
                                            bloc: ForgotPasswordBloc(
                                              Injector.of(context).userRepository,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          LoginButton(
                            emailLoginBloc: _emailLoginBloc,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: GoogleSignInButton(
                              googleSignInBloc: _googleSignInBloc,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 48.0),
                            child: FlatButton(
                              child: Text(
                                s.new_account,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return RegisterPage(
                                        userRepository: Injector.of(context)
                                            .userRepository,
                                      );
                                    },
                                  ),
                                );
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _emailLoginBloc.dispose();
    _googleSignInBloc.dispose();

    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_emailLoginBloc.isLoading$.value || _googleSignInBloc.isLoading$.value) {
      final s = S.of(context);
      final exitSignIn = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(s.exit_login),
            content: Text(s.exit_login_message),
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
      return exitSignIn ?? false;
    }
    return true;
  }

  _showSnackBar(message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoginMessage(LoginMessage message) async {
    final s = S.of(context);
    if (message is LoginMessageSuccess) {
      _showSnackBar(s.login_success);
      await Future.delayed(const Duration(seconds: 2));
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    if (message is LoginMessageError) {
      final error = message.error;
      print('[DEBUG] error=$error');

      if (error is NetworkError) {
        _showSnackBar(s.network_error);
      }
      if (error is TooManyRequestsError) {
        _showSnackBar(s.too_many_requests_error);
      }
      if (error is UserNotFoundError) {
        _showSnackBar(s.user_not_found_error);
      }
      if (error is WrongPasswordError) {
        _showSnackBar(s.wrong_password_error);
      }
      if (error is InvalidEmailError) {
        _showSnackBar(s.invalid_email_error);
      }
      if (error is EmailAlreadyInUserError) {
        _showSnackBar(s.email_already_in_use_error);
      }
      if (error is WeakPasswordError) {
        _showSnackBar(s.wrong_password_error);
      }
      if (error is UserDisabledError) {
        _showSnackBar(s.user_disabled_error);
      }
      if (error is InvalidCredentialError) {
        _showSnackBar(s.invalid_credential_error);
      }
      if (error is AccountExistsWithDifferenceCredentialError) {
        _showSnackBar(s.account_exists_with_different_credential_error);
      }
      if (error is OperationNotAllowedError) {
        _showSnackBar(s.operation_not_allowed_error);
      }
      if (error is GoogleSignInCanceledError) {
        _showSnackBar(s.google_sign_in_cancelled_error);
      }

      if (error is UnknownError) {
        _showSnackBar(s.error_occurred);
      }
    }
  }
}