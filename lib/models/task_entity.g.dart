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
      project: json['project'] as String,
      assignedTo: json['assigned_to'] as String,
      createdBy: json['created_by'] as String,
      modifiedBy: json['modified_by'] as String,
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
      'project': instance.project,
      'assigned_to': instance.assignedTo,
      'created_by': instance.createdBy,
      'modified_by': instance.modifiedBy,
      'created_on': timestampToJson(instance.createdOn),
      'modified_on': timestampToJson(instance.modifiedOn),
      'due_date': timestampToJson(instance.dueDate),
      'completed_date': timestampToJson(instance.completedDate),
      'complete': instance.complete
    };
