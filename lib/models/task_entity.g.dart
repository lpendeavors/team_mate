// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskEntity _$TaskEntityFromJson(Map<String, dynamic> json) {
  return TaskEntity(
      documentID: json['documentId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      project: documentReferenceFromJson(json['project'] as DocumentReference),
      assignedTo:
          documentReferenceFromJson(json['assigned_to'] as DocumentReference),
      createdBy:
          documentReferenceFromJson(json['created_by'] as DocumentReference),
      modifiedBy:
          documentReferenceFromJson(json['modified_by'] as DocumentReference),
      createdOn: timestampFromJson(json['created_on'] as Timestamp),
      modifiedOn: timestampFromJson(json['modified_on'] as Timestamp),
      dueDate: timestampFromJson(json['due_date'] as Timestamp),
      completedDate: timestampFromJson(json['completed_date'] as Timestamp),
      complete: json['complete'] as bool);
}

Map<String, dynamic> _$TaskEntityToJson(TaskEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentID,
      'title': instance.title,
      'description': instance.description,
      'project': documentReferenceToJson(instance.project),
      'assigned_to': documentReferenceToJson(instance.assignedTo),
      'created_by': documentReferenceToJson(instance.createdBy),
      'modified_by': documentReferenceToJson(instance.modifiedBy),
      'created_on': timestampToJson(instance.createdOn),
      'modified_on': timestampToJson(instance.modifiedOn),
      'due_date': timestampToJson(instance.dueDate),
      'completed_date': timestampToJson(instance.completedDate),
      'complete': instance.complete
    };
