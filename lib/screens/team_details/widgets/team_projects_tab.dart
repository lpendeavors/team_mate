import 'package:flutter/material.dart';
import 'package:team_mate/screens/team_details/team_details_state.dart';
import 'package:team_mate/screens/team_details/widgets/team_projects_list_item.dart';
import 'package:team_mate/generated/i18n.dart';

class TeamMateProjectsTab extends StatelessWidget {
  final List<ProjectItem> projects;

  const TeamMateProjectsTab({
    @required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
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
              S.of(context).projects_list_empty,
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: projects.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return ProjectsListItem(
          projectItem: projects[index],
          openProject: (project) => Navigator.of(context).pushNamed(
            '/project_details',
            arguments: projects[index].id,
          ),
        );
      },
    );
  }
}