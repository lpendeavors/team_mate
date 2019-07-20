import 'package:flutter/material.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/widgets/root_drawer.dart';
import 'package:team_mate/widgets/tm_navigation_tile.dart';

class TeamMateDrawer extends StatelessWidget {
  final GlobalKey<NavigatorState> navigator;

  const TeamMateDrawer({
    Key key,
    this.navigator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] MyDrawer build');

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _TeamMateDrawerHeader(),
          _TeamMateTasksTile(navigator),
          _TeamMateTeamsTile(navigator),
          _TeamMateProfileTile(navigator),
          _TeamMateAboutTile(navigator),
          _TeamMateLogoutTile(navigator),
        ],
      ),
    );
  }
}

class _TeamMateDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              S.of(context).app_title,
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              S.of(context).app_branding,
              style: TextStyle(
                color: Theme.of(context).backgroundColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: Text(
              "Larry Legend",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _TeamMateTasksTile extends StatelessWidget {
  final GlobalKey<NavigatorState> navigator;

  const _TeamMateTasksTile(this.navigator, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DrawerControllerState drawerControllerState = RootDrawer.of(context);

    return TeamMateNavigationTile(
      label: S.of(context).tasks_page_title,
      tapAction: () {
        drawerControllerState.close();
        navigator.currentState.popUntil(ModalRoute.withName('/'));
      },
    );
  }
}

class _TeamMateTeamsTile extends StatelessWidget {
  final GlobalKey<NavigatorState> navigator;

  const _TeamMateTeamsTile(this.navigator, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DrawerControllerState drawerControllerState = RootDrawer.of(context);

    return TeamMateNavigationTile(
      label: S.of(context).teams_page_title,
      tapAction: () {
        drawerControllerState.close();
        navigator.currentState.pushNamedAndRemoveUntil(
          '/teams',
          ModalRoute.withName('/'),
        );
      },
    );
  }
}

class _TeamMateProfileTile extends StatelessWidget {
  final GlobalKey<NavigatorState> navigator;

  const _TeamMateProfileTile(this.navigator, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DrawerControllerState drawerControllerState = RootDrawer.of(context);

    return TeamMateNavigationTile(
      label: S.of(context).profile_page_title,
      tapAction: () {
        drawerControllerState.close();
        navigator.currentState.pushNamedAndRemoveUntil(
          '/profile',
          ModalRoute.withName('/'),
        );
      },
    );
  }
}

class _TeamMateAboutTile extends StatelessWidget {
  final GlobalKey<NavigatorState> navigator;

  const _TeamMateAboutTile(this.navigator, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DrawerControllerState drawerControllerState = RootDrawer.of(context);

    return TeamMateNavigationTile(
      label: S.of(context).about_page_title,
      tapAction: () {
        drawerControllerState.close();
        navigator.currentState.pushNamedAndRemoveUntil(
          '/about',
          ModalRoute.withName('/'),
        );
      },
    );
  }
}

class _TeamMateLogoutTile extends StatelessWidget {
  final GlobalKey<NavigatorState> navigator;

  const _TeamMateLogoutTile(this.navigator, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DrawerControllerState drawerControllerState = RootDrawer.of(context);

    return TeamMateNavigationTile(
      label: S.of(context).logout_page_title,
      tapAction: () {
        drawerControllerState.close();
      },
    );
  }
}
