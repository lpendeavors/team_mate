// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamEntity _$TeamEntityFromJson(Map<String, dynamic> json) {
  return TeamEntity(
      documentID: json['documentId'] as String,
      name: json['name'] as String,
      members:
          (json['team_members_ids'] as List)?.map((e) => e as String)?.toList(),
      createdAt: timestampFromJson(json['created_at'] as Timestamp),
      createdBy: json['created_by'] as String,
      updatedAt: timestampFromJson(json['updated_at'] as Timestamp));
}

Map<String, dynamic> _$TeamEntityToJson(TeamEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentID,
      'name': instance.name,
      'team_members_ids': instance.members,
      'created_at': timestampToJson(instance.createdAt),
      'updated_at': timestampToJson(instance.updatedAt),
      'created_by': instance.createdBy
    };
