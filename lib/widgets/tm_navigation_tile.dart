import 'package:flutter/material.dart';

class TeamMateNavigationTile extends StatelessWidget {
  final Function() tapAction;
  final String label;

  const TeamMateNavigationTile({
    this.tapAction,
    this.label,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Center(
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).primaryColorLight,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: tapAction,
    );
  }
}