import 'dart:async';

import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/widgets/root_scaffold.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/screens/team_details/team_details_bloc.dart';
import 'package:team_mate/screens/team_details/team_details_bloc.dart';
import 'package:team_mate/screens/team_details/team_details_state.dart';
import 'package:flutter/material.dart';

enum TeamActions { addMember, addProject }

class TeamDetailsPage extends StatefulWidget {
  final UserBloc userBloc;
  final TeamDetailsBloc Function() initTeamDetailsBloc;

  const TeamDetailsPage({
    Key key,
    @required this.userBloc,
    @required this.initTeamDetailsBloc,
  }) : super(key: key);

  @override
  _TeamDetailsPageState createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> with SingleTickerProviderStateMixin {
  TeamDetailsBloc _teamDetailsBloc;
  List<StreamSubscription> _subscriptions;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _teamDetailsBloc = widget.initTeamDetailsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/'))),
      _teamDetailsBloc.message$.listen(_showMessageResult),
    ];
    _tabController = TabController(vsync: this, length: 2);
  }

  void _showMessageResult(TeamDetailMessage message) {
    print('[DEBUG] team_detail_message=$message');
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _teamDetailsBloc.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TeamDetailsState>(
      stream: _teamDetailsBloc.teamDetailsState$,
      initialData: _teamDetailsBloc.teamDetailsState$.value,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              snapshot.data.teamDetails != null ? snapshot.data.teamDetails.name : "Project",
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => RootScaffold.openDrawer(context),
              color: Theme.of(context).primaryColorDark,
            ),
            actions: <Widget>[
              PopupMenuButton<TeamActions>(
                icon: Icon(Icons.settings, color: Theme.of(context).primaryColorDark),
                onSelected: (TeamActions result) {
                  switch (result) {
                    case TeamActions.addMember:
                      print('add member');
                      break;
                    case TeamActions.addProject:
                      print('add project');
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: TeamActions.addProject,
                    child: Text(
                      'New Project',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: TeamActions.addMember,
                    child: Text(
                      'New Member',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColorDark,
              unselectedLabelColor: Theme.of(context).primaryColor,
              indicatorColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
              ),
              tabs: <Widget>[
                Tab(text: 'Projects'),
                Tab(text: 'Members'),
              ],
            ),
          ),
          body: SafeArea(
            child: Container(
              color: Theme.of(context).backgroundColor,
              child: Stack(
                children: <Widget>[
                  TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      Center(
                        child: Text('test'),
                      ),
                      Center(
                        child: Text('test2'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}