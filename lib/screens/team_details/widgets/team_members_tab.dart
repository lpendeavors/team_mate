import 'package:flutter/material.dart';
import 'package:team_mate/screens/team_details/team_details_state.dart';
import 'package:team_mate/screens/team_details/widgets/team_members_list_item.dart';
import 'package:team_mate/generated/i18n.dart';

class TeamMateMembersTab extends StatelessWidget {
  final List<MemberItem> members;

  const TeamMateMembersTab({
    @required this.members,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add,
              size: 48,
              color: Theme.of(context).primaryColorDark,
            ),
            Text(
              S.of(context).members_list_empty,
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: members.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return MembersListItem(
          memberItem: members[index],
        );
      },
    );
  }
}