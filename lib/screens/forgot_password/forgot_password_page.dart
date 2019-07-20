import 'dart:async';

import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_bloc.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_state.dart';
import 'package:team_mate/screens/forgot_password//widgets/email_text_field.dart';
import 'package:team_mate/screens/forgot_password/widgets/send_email_button.dart';
import 'package:team_mate/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  StreamSubscription _subscription;

  @override
  void didChangeDependencies() {
    _subscription ??= BlocProvider.of<ForgotPasswordBloc>(context)
        .message$
        .listen(_handleMessage);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bloc = BlocProvider.of<ForgotPasswordBloc>(context);

    return WillPopScope(
      onWillPop: () => _onWillPop(bloc),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(s.forgot_password_title),
          ),
        body: SafeArea(
          child: Container(
            constraints: BoxConstraints.expand(),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 12),
                        const EmailTextField(),
                        SizedBox(height: 8),
                        StreamBuilder<bool>(
                          stream: bloc.isLoading$,
                          initialData: bloc.isLoading$.value,
                          builder: (context, snapshot) {
                            return LoadingIndicator(
                              isLoading: snapshot.data,
                              key: ValueKey(snapshot.data),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        SendEmailButton(),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop(ForgotPasswordBloc bloc) async {
    if (bloc.isLoading$.value) {
      final s = S.of(context);
      final exitSendEmail = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(s.exit_send_email_message),
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
      return exitSendEmail ?? false;
    }
    return true;
  }

  _handleMessage(ForgotPasswordMessage message) {
    final s = S.of(context);
    if (message is InvalidInformation) {
      _showSnackBar(s.invalid_email_address);
    }
    if (message is SendPasswordResetEmailSuccess) {
      _showSnackBar(s.send_password_reset_email_success);
    }
    if (message is SendPasswordResetEmailFailure) {
      final ForgotPasswordError  error = message.error;
      if (error is UnknownError) {
        print('[FORGOT_PASSWORD] ${error.error}');
        _showSnackBar(s.error_occurred);
      }
      if (error is UserNotFoundError) {
        _showSnackBar(s.user_not_found_error);
      }
      if (error is InvalidEmailError) {
        _showSnackBar(s.invalid_email_address);
      }
    }
  }

  _showSnackBar(String message) {
    Scaffold.of(context, nullOk: true)?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

