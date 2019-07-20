import 'package:team_mate/models/team_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestoreTeamRepository {
  Stream<TeamEntity> teamById({
    @required String teamId,
  });

  Stream<List<TeamEntity>> teamsByUser({
    @required String userId,
  });

  Future<Map<String, String>> addTeam({
    @required String userId,
    @required String newTeamName,
  });
}