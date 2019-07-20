import 'package:flutter/material.dart';
import 'package:team_mate/screens/register/register_bloc.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_form_field.dart';

class FullNameTextField extends StatelessWidget {
  final FocusNode focusNode;
  final RegisterBloc bloc;
  final FocusNode emailFocusNode;

  const FullNameTextField({
    Key key,
    @required this.focusNode,
    @required this.bloc,
    @required this.emailFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeamMateFormField(
      inputType: TextInputType.text,
      inputAction: TextInputAction.next,
      selfFocusNode: focusNode,
      nextFocusNode: emailFocusNode,
      changedCallback: bloc.fullNameChanged,
      hintText: S.of(context).full_name,
    );
  }
}