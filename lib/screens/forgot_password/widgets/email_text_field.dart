import 'package:flutter/material.dart';
import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/screens/forgot_password/forgot_password_bloc.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<ForgotPasswordBloc>(context);

    return TextField(
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      maxLines: 1,
      onChanged: bloc.emailChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.email,
          color: Colors.black54,
        ),
        hintText: "Email *",
        hintStyle: TextStyle(
          color: Colors.black54,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: 8.0,
        ),
      ),
    );
  }
}