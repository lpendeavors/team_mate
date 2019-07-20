import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/data/project/firestore_project_repository.dart';
import 'package:team_mate/models/project_entity.dart';

class FirestoreProjectRepositoryImpl implements FirestoreProjectRepository {
  final Firestore _firestore;

  const FirestoreProjectRepositoryImpl(this._firestore);

  @override
  Future<Map<String, String>> addNewProject({ProjectEntity newProject}) {
    if (newProject == null) {
      return Future.error("New Project cannot be null");
    }

    final TransactionHandler transactionHandler = (transaction) async {
      final project = <String, dynamic>{
        'name': newProject.name,
        'description': newProject.description,
        'due_date': newProject.dueDate,
        'team_id': newProject.team,
        'created_by': newProject.createdBy,
        'created_on': FieldValue.serverTimestamp(),
        'updated_on': FieldValue.serverTimestamp(),
        'updated_by': newProject.createdBy,
      };
      _firestore.collection('projects').add(project)
        .then((doc) {
          return <String, String>{
            'id': doc.documentID,
            'name': newProject.name,
            'status': 'added',
          };
        }
      );
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
}