import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

const kListStringEquality = ListEquality<String>();

const kMapStringTimestampEquality = MapEquality<String, Timestamp>();

DocumentReference documentReferenceFromJson(DocumentReference ref) => ref;

DocumentReference documentReferenceToJson(DocumentReference ref) => ref;

Timestamp timestampFromJson(Timestamp timestamp) => timestamp;

Timestamp timestampToJson(Timestamp timestamp) => timestamp;

Map<String, Timestamp> mapStringTimestampFromJson(Map<dynamic, dynamic> map) =>
    map is Map<String, Timestamp> ? map : map.cast<String, Timestamp>();

Map<String, Timestamp> mapStringTimestampToJson(Map<String, Timestamp> map) =>
    map;

Map<String, dynamic> withId(DocumentSnapshot doc) => CombinedMapView([
  doc.data,
  <String, dynamic>{'documentId': doc.documentID}
]);