import 'dart:math';

import 'package:flutter/material.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/screens/teams/teams_state.dart';

class TeamsListItem extends StatefulWidget {
  final TeamItem teamItem;
  final void Function(String) openTeam;

  const TeamsListItem({
    Key key,
    @required this.teamItem,
    @required this.openTeam,
  }) : super(key: key);

  @override
  _TeamsListItemState createState() => _TeamsListItemState();
}

class _TeamsListItemState extends State<TeamsListItem> with SingleTickerProviderStateMixin<TeamsListItem> {
  AnimationController _animationController;
  Animation<Offset> _animationPosition;
  Animation<double> _animationScale;
  Animation<double> _animationOpacity;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _animationPosition = Tween(
      begin: Offset(2.0, 0),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut
      ),
    );

    _animationScale = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _animationOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final s = S.of(context);
    final item = widget.teamItem;

    var content = Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 21.0, horizontal: 25.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  color: themeData.primaryColorDark,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              item.memberCount.toString(),
              style: TextStyle(
                fontSize: 28.0,
                color: themeData.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    return FadeTransition(
      opacity: _animationOpacity,
      child: ScaleTransition(
        scale: _animationScale,
        child: SlideTransition(
          position: _animationPosition,
          child: InkWell(
            child: content,
            onTap: () => widget.openTeam(item.id),
          ),
          key: Key("${item.id}${Random().nextInt(1 << 32)}"),
        ),
      ),
    );
  }
}