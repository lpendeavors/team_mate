import 'package:flutter/material.dart';

class TeamMateFormField extends StatelessWidget {
  final TextInputAction inputAction;
  final TextInputType inputType;
  final FocusNode selfFocusNode;
  final FocusNode nextFocusNode;
  final Function(String) changedCallback;
  final String hintText;
  final bool doObscure;

  const TeamMateFormField({
    @required this.inputAction,
    @required this.inputType,
    @required this.selfFocusNode,
    @required this.changedCallback,
    this.hintText,
    this.nextFocusNode,
    this.doObscure
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: doObscure ?? false,
      keyboardType: inputType,
      onSubmitted: (_) {
        selfFocusNode.unfocus();
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },
      focusNode: selfFocusNode,
      textInputAction: inputAction,
      maxLines: 1,
      onChanged: changedCallback,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black54,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
    );
  }
}