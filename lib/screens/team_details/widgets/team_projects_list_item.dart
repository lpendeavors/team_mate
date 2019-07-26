import 'dart:math';

import 'package:flutter/material.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/screens/team_details/team_details_state.dart';

class ProjectsListItem extends StatefulWidget {
  final ProjectItem projectItem;
  final void Function(String) openProject;

  const ProjectsListItem({
    Key key,
    @required this.projectItem,
    @required this.openProject,
  }) : super(key: key);

  @override
  _ProjectsListItemState createState() => _ProjectsListItemState();
}

class _ProjectsListItemState extends State<ProjectsListItem> with SingleTickerProviderStateMixin {
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
        curve: Curves.easeOut,
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
    final item = widget.projectItem;

    var content = Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 21.0, horizontal: 25.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: TextStyle(
                      color: themeData.primaryColorDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 24.0,
                    ),
                  ),
                  Text(
                    'Due ${item.dueDate}',
                    style: TextStyle(
                      color: themeData.primaryColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 20.0,
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
          child: content,
          onTap: () => widget.openProject(item.id),
        ),
        key: Key("${item.id}${Random().nextInt(1 << 32)}"),
      ),
    );
  }
}