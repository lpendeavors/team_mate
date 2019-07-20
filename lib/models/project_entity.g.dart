// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectEntity _$ProjectEntityFromJson(Map<String, dynamic> json) {
  return ProjectEntity(
      documentID: json['documentId'] as String,
      team: json['team_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dueDate: timestampFromJson(json['due_date'] as Timestamp),
      createdBy: json['created_by'] as String,
      createdOn: timestampFromJson(json['created_on'] as Timestamp),
      updatedBy: json['updated_by'] as String,
      updatedOn: timestampFromJson(json['updated_on'] as Timestamp));
}

Map<String, dynamic> _$ProjectEntityToJson(ProjectEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentID,
      'team_id': instance.team,
      'name': instance.name,
      'description': instance.description,
      'due_date': timestampToJson(instance.dueDate),
      'created_on': timestampToJson(instance.createdOn),
      'updated_on': timestampToJson(instance.updatedOn),
      'created_by': instance.createdBy,
      'updated_by': instance.updatedBy
    };
