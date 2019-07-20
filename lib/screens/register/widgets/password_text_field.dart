import 'package:flutter/material.dart';
import 'package:team_mate/screens/register/register_bloc.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_form_field.dart';

class PasswordTextField extends StatelessWidget {
  final FocusNode focusNode;
  final RegisterBloc bloc;

  const PasswordTextField({
    Key key,
    @required this.focusNode,
    @required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeamMateFormField(
      inputType: TextInputType.text,
      inputAction: TextInputAction.done,
      selfFocusNode: focusNode,
      changedCallback: bloc.passwordChanged,
      hintText: S.of(context).password,
      doObscure: true,
    );
  }
}