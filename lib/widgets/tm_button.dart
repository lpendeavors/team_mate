import 'package:flutter/material.dart';

class TeamMateButton extends StatelessWidget {
  final Function() pressedCallback;
  final String label;
  final Color altColor;

  const TeamMateButton({
    @required this.pressedCallback,
    @required this.label,
    this.altColor,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      color: altColor != null ? altColor : Theme.of(context).buttonColor,
      splashColor: Colors.white,
      onPressed: pressedCallback,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.button.copyWith(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}