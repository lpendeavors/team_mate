import 'package:team_mate/models/project_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestoreProjectRepository {
  Stream<List<ProjectEntity>> projectsByTeam({
    @required String teamId,
  });

  Future<Map<String, String>> addNewProject({
    @required ProjectEntity newProject
  });
}