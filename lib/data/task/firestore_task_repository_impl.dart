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
}