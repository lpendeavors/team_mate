import 'package:flutter/material.dart';
import 'package:team_mate/screens/register/register_bloc.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/tm_button.dart';

class RegisterButton extends StatelessWidget {
  final RegisterBloc bloc;

  const RegisterButton({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeamMateButton(
      label: S.of(context).register,
      pressedCallback: bloc.submitRegister,
    );
  }
}