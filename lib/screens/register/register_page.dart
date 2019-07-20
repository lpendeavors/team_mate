import 'dart:async';

import 'package:team_mate/data/user/firebase_user_repository.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/screens/register/register_bloc.dart';
import 'package:team_mate/screens/register/register_state.dart';
import 'package:team_mate/screens/register/widgets/full_name_text_field.dart';
import 'package:team_mate/screens/register/widgets/email_text_field.dart';
import 'package:team_mate/screens/register/widgets/password_text_field.dart';
import 'package:team_mate/screens/register/widgets/register_button.dart';
import 'package:team_mate/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final FirebaseUserRepository userRepository;

  const RegisterPage({
    Key key,
    @required this.userRepository
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterBloc _bloc;
  List<StreamSubscription> _subscriptions;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _fullNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _bloc = RegisterBloc(widget.userRepository);

    _subscriptions = [_bloc.message$.listen(_showRegisterMessage)];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
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
                            padding: EdgeInsets.only(top: 97.0, bottom: 47.0),
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
                                  S.of(context).register_title,
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
                            child: FullNameTextField(
                              bloc: _bloc,
                              focusNode: _fullNameFocusNode,
                              emailFocusNode: _emailFocusNode,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: EmailTextField(
                              bloc: _bloc,
                              focusNode: _emailFocusNode,
                              passwordFocusNode: _passwordFocusNode,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: PasswordTextField(
                              bloc: _bloc,
                              focusNode: _passwordFocusNode
                            ),
                          ),
                          SizedBox(height: 8.0),
                          StreamBuilder<bool>(
                            stream: _bloc.isLoading$,
                            initialData: _bloc.isLoading$.value,
                            builder: (context, snapshot) {
                              return LoadingIndicator(
                                isLoading: snapshot.data,
                                key: ValueKey(snapshot.data),
                              );
                            },
                          ),
                          SizedBox(height: 8.0),
                          RegisterButton(bloc: _bloc),
                          SizedBox(height: 12),
                          Padding(
                            padding: EdgeInsets.only(top: 112.0),
                            child: FlatButton(
                              child: Text(
                                s.existing_account,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _bloc.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_bloc.isLoading$.value) {
      final s = S.of(context);
      final exitRegister = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(s.exit_register),
            content: Text(s.exit_register_message),
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
      return exitRegister ?? false;
    }
    return true;
  }

  _showSnackBar(String message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  _showRegisterMessage(RegisterMessage message) async {
    final s = S.of(context);
    if (message is RegisterMessageError) {
      _showSnackBar(s.register_success);
    }
    if (message is RegisterMessageError) {
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
        _showSnackBar(s.weak_password_error);
      }

      if (error is UnknownError) {
        print('[DEBUG] error=${error.error}');
        _showSnackBar(s.error_occurred);
      }
    }
  }
}