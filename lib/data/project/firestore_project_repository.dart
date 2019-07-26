import 'package:team_mate/models/project_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestoreProjectRepository {
  Stream<ProjectEntity> getById({
  @required String uid,
  });

  Stream<List<ProjectEntity>> projectsByTeam({
    @required String teamId,
  });

  Future<Map<String, String>> saveProject(
    String projectId,
    @required String projectName,
    @required String projectDescription,
    @required DateTime projectDueDate,
    @required String userId,
    @required String teamId,
  );
}