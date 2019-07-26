import 'dart:async';

import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:team_mate/widgets/root_scaffold.dart';
import 'package:team_mate/generated/i18n.dart';
import 'package:team_mate/user_bloc/user_bloc.dart';
import 'package:team_mate/screens/teams/widgets/team_list_item.dart';
import 'package:team_mate/screens/teams/teams_bloc.dart';
import 'package:team_mate/screens/teams/teams_state.dart';
import 'package:flutter/material.dart';

class TeamsPage extends StatefulWidget {
  final UserBloc userBloc;
  final TeamsBloc Function() initTeamsBloc;

  const TeamsPage({
    Key key,
    @required this.userBloc,
    @required this.initTeamsBloc,
  }) : super(key: key);

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  List<StreamSubscription> _subscriptions;
  TeamsBloc _teamsBloc;

  @override
  void initState() {
    super.initState();

    _teamsBloc = widget.initTeamsBloc();
    _subscriptions = [
      widget.userBloc.loginState$
        .where((state) => state is Unauthenticated)
        .listen((_) => Navigator.popUntil(context, ModalRoute.withName('/'))),
//      _teamsBloc.addedMessage$.listen(_showTeamResult);
    ];
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _teamsBloc.dispose();
    print('_TeamsPageState#dispose');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text(
          S.of(context).teams_page_title,
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
          IconButton(
            color: Theme.of(context).primaryColorDark,
            icon: Icon(Icons.add),
            onPressed: _showNewTeamDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<TeamListState>(
          stream: _teamsBloc.teamListState$,
          initialData: _teamsBloc.teamListState$.value,
          builder: (context, snapshot) {
            var data = snapshot.data;
            print('teams length=${data.teamItems.length}, data=$data');

            if (data.error != null) {
              return Center(
                child: Text(
                  S.of(context).error_occurred,
                  style: Theme.of(context).textTheme.subhead,
                ),
              );
            }

            if (data.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (data.teamItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      size: 48,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    Text(
                      S.of(context).teams_list_empty,
                      style: Theme.of(context).textTheme.body1.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: data.teamItems.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return TeamsListItem(
                  teamItem: data.teamItems[index],
                  openTeam: (team) => Navigator.of(context).pushNamed(
                    '/team_details',
                    arguments: data.teamItems[index].id,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showNewTeamDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).new_team_title),
          content: TextField(
            onChanged: _teamsBloc.teamNameChanged,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: S.of(context).new_team_hint,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).no),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text(S.of(context).save_team),
              onPressed: () {
                _teamsBloc.addNewTeam();
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      }
    );
  }
}