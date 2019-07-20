import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/models/firebase_model.dart';
import 'package:team_mate/util/model_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'task_entity.g.dart';

@immutable
@JsonSerializable()
class TaskEntity implements FirebaseModel {
  @JsonKey(name: 'documentId')
  final String documentID;
  final String title;
  final String description;
  @JsonKey(
    fromJson: documentReferenceFromJson,
    toJson: documentReferenceToJson,
  )
  final DocumentReference project;
  @JsonKey(
    name: 'assigned_to',
    fromJson: documentReferenceFromJson,
    toJson: documentReferenceToJson,
  )
  final DocumentReference assignedTo;
  @JsonKey(
    name: 'created_by',
    fromJson: documentReferenceFromJson,
    toJson: documentReferenceToJson,
  )
  final DocumentReference createdBy;
  @JsonKey(
    name: 'modified_by',
    fromJson: documentReferenceFromJson,
    toJson: documentReferenceToJson,
  )
  final DocumentReference modifiedBy;
  @JsonKey(
    name: 'created_on',
    fromJson: timestampFromJson,
    toJson: timestampToJson
  )
  final Timestamp createdOn;
  @JsonKey(
      name: 'modified_on',
      fromJson: timestampFromJson,
      toJson: timestampToJson
  )
  final Timestamp modifiedOn;
  @JsonKey(
      name: 'due_date',
      fromJson: timestampFromJson,
      toJson: timestampToJson
  )
  final Timestamp dueDate;
  @JsonKey(
      name: 'completed_date',
      fromJson: timestampFromJson,
      toJson: timestampToJson
  )
  final Timestamp completedDate;
  final bool complete;

  const TaskEntity({
    this.documentID,
    this.title,
    this.description,
    this.project,
    this.assignedTo,
    this.createdBy,
    this.modifiedBy,
    this.createdOn,
    this.modifiedOn,
    this.dueDate,
    this.completedDate,
    this.complete,
  });

  factory TaskEntity.fromDocumentSnapshot(DocumentSnapshot doc) => _$TaskEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$TaskEntityToJson(this);

  @override
  String get id => this.documentID;

  @override
  bool operator ==(Object other) {
    identical(this, other) ||
    other is TaskEntity &&
        runtimeType == other.runtimeType &&
        documentID == other.documentID &&
        title == other.title &&
        description == other.description &&
        project == other.project &&
        assignedTo == other.assignedTo &&
        createdBy == other.createdBy &&
        modifiedBy == other.modifiedBy &&
        createdOn == other.createdOn &&
        modifiedOn == other.modifiedOn &&
        dueDate == other.dueDate &&
        completedDate == other.completedDate &&
        complete == other.complete;
  }

  @override
  int get hashCode =>
      documentID.hashCode ^
      title.hashCode ^
      description.hashCode ^
      assignedTo.hashCode ^
      assignedTo.hashCode ^
      createdBy.hashCode ^
      modifiedBy.hashCode ^
      createdOn.hashCode ^
      modifiedOn.hashCode ^
      dueDate.hashCode ^
      completedDate.hashCode ^
      complete.hashCode;

  @override
  String toString() => 'TaskEntity{documentID: $documentID, title: $title, description: $description '
      'assignedTo: $assignedTo, createdBy: $createdBy, modifiedBy: $modifiedBy, createdOn: $createdOn '
      'modifiedOn: $modifiedOn, dueDate: $dueDate, completedDate: $completedDate, complete: $complete, '
      'project: $project}';
}