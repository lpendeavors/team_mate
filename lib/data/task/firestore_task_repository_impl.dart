import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/data/task/firestore_task_repository.dart';
import 'package:team_mate/models/task_entity.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreTaskRepositoryImpl implements FirestoreTaskRepository {
  final Firestore _firestore;

  const FirestoreTaskRepositoryImpl(this._firestore);

  @override
  Stream<List<TaskEntity>> tasksByProject({String projectId}) {
    if (projectId == null) {
      return Observable.error("Project ID must not be null");
    }

    return _firestore.collection('tasks')
        .where('project', isEqualTo: projectId)
        .orderBy('dueDate')
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<TaskEntity>> tasksByUser({String userId}) {
    if (userId == null) {
      return Observable.error("User ID must not be null");
    }

    return _firestore.collection('tasks')
        .where('assigned_to', isEqualTo: userId)
        .orderBy('dueDate')
        .snapshots()
        .map(_toEntities);
  }

  List<TaskEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return TaskEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Stream<TaskEntity> getById({String taskId}) {
    return _firestore.collection('tasks').document(taskId)
        .snapshots()
        .map((snapshot) => TaskEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Future<Map<String, String>> saveTask(
    String taskId,
    String taskTitle,
    String taskDescription,
    DateTime taskDueDate,
    String taskAssignee,
    String userId,
    String projectId
  ) {
    if (taskTitle == null) {
      return Future.error("taskTitle cannot be null");
    }
    if (taskDescription == null) {
      return Future.error("taskDescription cannot be null");
    }
    if (taskDueDate == null) {
      return Future.error("taskDueDate cannot be null");
    }
    if (taskAssignee == null) {
      return Future.error("taskAssignee cannot be null");
    }
    if (userId == null) {
      return Future.error("userId cannot be null");
    }
    if (projectId == null) {
      return Future.error("projectId cannot be null");
    }

    TransactionHandler transactionHandler = (transaction) async {
      final task = <String, dynamic>{
        'title': taskTitle,
        'description': taskDescription,
        'due_date': taskDueDate.subtract(Duration(hours: 2)),
        'project_id': projectId,
        'updated_on': FieldValue.serverTimestamp(),
        'updated_by': userId,
      };

      if (taskId != null) {
        _firestore.collection('tasks').document(taskId)
          .setData(task, merge: true).then((_) {
            return <String, String>{
              'id': taskId,
              'title': taskTitle,
              'status': 'updatted',
            };
        });
      } else {
        task.addAll(<String, dynamic>{
          'created_by': userId,
          'created_on': FieldValue.serverTimestamp(),
        });
        _firestore.collection('tasks').add(task)
          .then((doc) {
            return <String, String>{
              'id': doc.documentID,
              'title': taskTitle,
              'status': 'added',
            };
          }
        );
      }
    };

    return _firestore.runTransaction(transactionHandler).then(
        (result) => result is Map<String, String> ? result : result.cast<String, String>()
    );
  }
}