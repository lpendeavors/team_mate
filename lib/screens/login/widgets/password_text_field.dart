import 'package:flutter/material.dart';
import 'package:team_mate/screens/login/email_login_bloc.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_form_field.dart';

class PasswordTextField extends StatelessWidget {
  final FocusNode focusNode;
  final EmailLoginBloc emailLoginBloc;

  const PasswordTextField({Key key, this.focusNode, this.emailLoginBloc});

  @override
  Widget build(BuildContext context) {
    return TeamMateFormField(
      inputType: TextInputType.text,
      inputAction: TextInputAction.done,
      changedCallback: emailLoginBloc.passwordChanged,
      selfFocusNode: focusNode,
      hintText: S.of(context).password,
      doObscure: true,
    );
  }
}