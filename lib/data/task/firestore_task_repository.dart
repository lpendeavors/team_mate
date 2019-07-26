import 'package:team_mate/models/task_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestoreTaskRepository {
  Stream<List<TaskEntity>> tasksByUser({
    @required String userId
  });

  Stream<List<TaskEntity>> tasksByProject({
    @required String projectId
  });

  Stream<TaskEntity> getById({
    @required String taskId
  });

  Future<Map<String, String>> saveTask(
    @required String taskId,
    @required String taskTitle,
    @required String taskDescription,
    @required DateTime taskDueDate,
    @required String taskAssignee,
    @required String userId,
    @required String projectId,
  );
}