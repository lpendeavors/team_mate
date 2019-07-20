import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:team_mate/models/firebase_model.dart';
import 'package:team_mate/util/model_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'team_entity.g.dart';

@immutable
@JsonSerializable()
class TeamEntity implements FirebaseModel {
  @JsonKey(name: 'documentId')
  final String documentID;
  final String name;
  @JsonKey(
    name: 'team_members_ids',
  )
  final List<String> members;
  @JsonKey(
    name: 'created_at',
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp createdAt;
  @JsonKey(
    name: 'updated_at',
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp updatedAt;
  @JsonKey(
    name: 'created_by',
  )
  final String createdBy;

  const TeamEntity({
    this.documentID,
    this.name,
    this.members,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  factory TeamEntity.fromDocumentSnapshot(DocumentSnapshot doc) => _$TeamEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$TeamEntityToJson(this);

  @override
  String get id => this.documentID;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TeamEntity &&
      runtimeType == other.runtimeType &&
      documentID == other.documentID &&
      members == other.members &&
      createdAt == other.createdAt &&
      createdBy == other.createdBy &&
      updatedAt == other.updatedAt;

  @override
  int get hashCode =>
    documentID.hashCode ^
    name.hashCode ^
    members.hashCode ^
    createdAt.hashCode ^
    createdBy.hashCode ^
    updatedAt.hashCode;

  @override
  String toString() => 'TeamEntity{documentID: $documentID, name: $name, members: $members, createdAt: $createdAt '
      'createdBy: $createdBy, updatedAt: $updatedAt}';
}