import 'dart:math';

import 'package:flutter/material.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/screens/team_details/team_details_state.dart';

class MembersListItem extends StatefulWidget {
  final MemberItem memberItem;

  const MembersListItem({
    Key key,
    @required this.memberItem,
  }) : super(key: key);

  @override
  _MembersListItemState createState() => _MembersListItemState();
}

class _MembersListItemState extends State<MembersListItem> with SingleTickerProviderStateMixin {
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
    final item = widget.memberItem;

    var content = Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 25),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.fullName,
                    style: TextStyle(
                      color: themeData.primaryColorDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 24.0,
                    ),
                  ),

                ],
              ),
            ),
            Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
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
        child: InkWell(
          child: content
        ),
      key: Key("${item.id}${Random().nextInt(1 << 32)}"),
      ),
    );
  }
}