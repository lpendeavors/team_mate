import 'package:flutter/material.dart';
import 'package:team_mate/screens/register/register_bloc.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_form_field.dart';

class EmailTextField extends StatelessWidget {
  final RegisterBloc bloc;
  final FocusNode focusNode;
  final FocusNode passwordFocusNode;

  const EmailTextField({
    Key key,
    this.bloc,
    @required this.focusNode,
    @required this.passwordFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeamMateFormField(
      inputType: TextInputType.emailAddress,
      inputAction: TextInputAction.next,
      selfFocusNode: focusNode,
      nextFocusNode: passwordFocusNode,
      changedCallback: bloc.emailChanged,
      hintText: S.of(context).email,
    );
  }
}