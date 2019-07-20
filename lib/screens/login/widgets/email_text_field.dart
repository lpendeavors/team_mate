import 'package:flutter/material.dart';
import 'package:team_mate/screens/login/email_login_bloc.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_form_field.dart';

class EmailTextField extends StatelessWidget {
  final EmailLoginBloc emailLoginBloc;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;

  const EmailTextField({
    Key key,
    this.emailLoginBloc,
    this.emailFocusNode,
    this.passwordFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeamMateFormField(
      inputAction: TextInputAction.next,
      inputType: TextInputType.emailAddress,
      selfFocusNode: emailFocusNode,
      nextFocusNode: passwordFocusNode,
      changedCallback: emailLoginBloc.emailChanged,
      hintText: S.of(context).email,
    );
  }
}