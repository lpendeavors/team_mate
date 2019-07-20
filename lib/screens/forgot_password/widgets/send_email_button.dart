import 'package:flutter/material.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_bloc.dart';
import 'package:team_mate/generated/i18n.dart';

class SendEmailButton extends StatelessWidget {
  const SendEmailButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ForgotPasswordBloc>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        color: Theme.of(context).accentColor,
        splashColor: Colors.white,
        onPressed: bloc.submit,
        elevation: 11,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(40.0),
          ),
        ),
        child: Text(
          S.of(context).send_email,
          style: Theme.of(context).textTheme.button.copyWith(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}