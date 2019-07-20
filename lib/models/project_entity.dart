import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/models/firebase_model.dart';
import 'package:team_mate/util/model_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'project_entity.g.dart';

@immutable
@JsonSerializable()
class ProjectEntity implements FirebaseModel {
  @JsonKey(name: 'documentId')
  final String documentID;
  @JsonKey(name: 'team_id')
  final String team;
  final String name;
  final String description;
  @JsonKey(
    name: 'due_date',
    toJson: timestampToJson,
    fromJson: timestampFromJson,
  )
  final Timestamp dueDate;
  @JsonKey(
    name: 'created_on',
    toJson: timestampToJson,
    fromJson: timestampFromJson,
  )
  final Timestamp createdOn;
  @JsonKey(
    name: 'updated_on',
    toJson: timestampToJson,
    fromJson: timestampFromJson,
  )
  final Timestamp updatedOn;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'updated_by')
  final String updatedBy;

  const ProjectEntity({
    this.documentID,
    this.team,
    this.name,
    this.description,
    this.dueDate,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
  });

  factory ProjectEntity.fromDocumentSnapshot(DocumentSnapshot doc) => _$ProjectEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$ProjectEntityToJson(this);

  @override
  String get id => this.documentID;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ProjectEntity &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      dueDate == other.dueDate &&
      team == other.team &&
      createdBy == other.createdBy &&
      createdOn == other.createdOn &&
      updatedBy == other.updatedBy &&
      updatedOn == other.updatedOn;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      team.hashCode ^
      createdBy.hashCode ^
      createdOn.hashCode ^
      updatedBy.hashCode ^
      updatedOn.hashCode;

  @override
  String toString() =>
      'ProjectEntity{id=$id, name=$name, description=$description, dueDate=$dueDate, createdBy=$createdBy'
      ' team=$team, createdBy=$createdBy, createdOn=$createdOn, updatedBy=$updatedBy, updatedOn=$updatedOn}';
}