import 'package:flutter/material.dart';

class TeamMateInputField extends StatelessWidget {
  final String hintText;
  final int maxLines;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final FocusNode selfFocusNode;
  final FocusNode nextFocusNode;
  final Function(String) changedCallback;

  const TeamMateInputField({
    this.maxLines,
    this.nextFocusNode,
    @required this.hintText,
    @required this.inputType,
    @required this.inputAction,
    @required this.changedCallback,
    @required this.selfFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: inputType,
      textInputAction: inputAction,
      onSubmitted: (_) {
        selfFocusNode.unfocus();
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        }
      },
      onChanged: changedCallback,
      focusNode: selfFocusNode,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).primaryColor,
        ),
        border: InputBorder.none,
      ),
      maxLines: maxLines ?? 1,
      style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}