import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/data/team/firestore_team_repository.dart';
import 'package:team_mate/models/team_entity.dart';

class FirestoreTeamRepositoryImpl implements FirestoreTeamRepository {
  final Firestore _firestore;

  const FirestoreTeamRepositoryImpl(this._firestore);

  @override
  Future<Map<String, String>> addTeam({String userId, String newTeamName}) {
    if (userId == null) {
      return Future.error("User Id cannot be null");
    }
    if (newTeamName == null) {
      return Future.error("Team Name cannot be null");
    }

    final TransactionHandler transactionHandler = (transaction) async {
      final newTeam = <String, dynamic>{
        'name': newTeamName,
        'created_by': userId,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'team_members_ids': [userId],
      };
      _firestore.collection('teams').add(newTeam)
        .then((doc) {
          return <String, String>{
            'id': doc.documentID,
            'name': newTeamName,
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
  Stream<List<TeamEntity>> teamsByUser({String userId}) {
    return _firestore.collection('teams')
        .where('team_members_ids', arrayContains: userId)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<TeamEntity> teamById({String teamId}) {
    return _firestore.collection('teams').document(teamId)
        .snapshots()
        .map((document) => TeamEntity.fromDocumentSnapshot(document));
  }

  List<TeamEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return TeamEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
  
}