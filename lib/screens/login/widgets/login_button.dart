import 'package:flutter/material.dart';
import 'package:team_mate/screens/login/email_login_bloc.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_button.dart';

class LoginButton extends StatelessWidget {
  final EmailLoginBloc emailLoginBloc;

  const LoginButton({Key key, this.emailLoginBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeamMateButton(
      pressedCallback: emailLoginBloc.submitLogin,
      label: S.of(context).login_title,
    );
  }
}