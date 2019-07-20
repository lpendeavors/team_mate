import 'package:flutter/material.dart';
import 'package:team_mate/screens/login/google_sign_in_bloc.dart';
import 'package:team_mate/widgets/tm_button.dart';

class GoogleSignInButton extends StatelessWidget {
  final GoogleSignInBloc googleSignInBloc;

  const GoogleSignInButton({Key key, this.googleSignInBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TeamMateButton(
      label: 'Google',
      pressedCallback: () => googleSignInBloc.submitLogin.add(null),
      altColor: Theme.of(context).accentColor,
    );
  }
}