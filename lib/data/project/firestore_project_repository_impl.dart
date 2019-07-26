import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/data/project/firestore_project_repository.dart';
import 'package:team_mate/models/project_entity.dart';

class FirestoreProjectRepositoryImpl implements FirestoreProjectRepository {
  final Firestore _firestore;

  const FirestoreProjectRepositoryImpl(this._firestore);

  @override
  Future<Map<String, String>> saveProject(
    String projectId,
    String projectName,
    String projectDescription,
    DateTime projectDueDate,
    String userId,
    String teamId
  ) {
    if (projectName == null) {
      return Future.error("projectName cannot be null");
    }
    if (projectDescription == null) {
      return Future.error("projectDescription cannot be null");
    }
    if (projectDueDate == null) {
      return Future.error("projectDueDate cannot be null");
    }
    if (userId == null) {
      return Future.error("userId cannot be null");
    }
    if (teamId == null) {
      return Future.error("teamId cannot be null");
    }

    final TransactionHandler transactionHandler = (transaction) async {
      final project = <String, dynamic>{
        'name': projectName,
        'description': projectDescription,
        'due_date': projectDueDate.subtract(Duration(hours: 2)),
        'team_id': teamId,
        'updated_on': FieldValue.serverTimestamp(),
        'updated_by': userId,
      };

      if (projectId != null) {
        _firestore.collection('projects').document(projectId)
          .setData(project, merge: true).then((_) {
            return <String, String>{
              'id': projectId,
              'name': projectName,
              'status': 'updated',
            };
        });
      } else {
        project.addAll(<String, dynamic>{
          'created_by': userId,
          'created_on': FieldValue.serverTimestamp(),
        });
        _firestore.collection('projects').add(project)
          .then((doc) {
            return <String, String>{
              'id': doc.documentID,
              'name': projectName,
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

  @override
  Stream<List<ProjectEntity>> projectsByTeam({String teamId}) {
    return _firestore.collection('projects')
        .where('team_id', isEqualTo: teamId)
        .snapshots()
        .map(_toEntities);
  }

  List<ProjectEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return ProjectEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

  @override
  Stream<ProjectEntity> getById({String uid}) {
    return _firestore.collection('projects').document(uid)
        .snapshots()
        .map((snapshot) => ProjectEntity.fromDocumentSnapshot(snapshot));
  }
}