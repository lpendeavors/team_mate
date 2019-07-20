import 'package:team_mate/models/task_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestoreTaskRepository {
  Stream<List<TaskEntity>> tasksByUser({
    @required String userId
  });

  Stream<List<TaskEntity>> tasksByProject({
    @required String projectId
  });
}