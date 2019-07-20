// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) {
  return UserEntity(
      documentID: json['documentId'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      isActive: json['is_active'] as bool,
      createdAt: timestampFromJson(json['created_at'] as Timestamp),
      updatedAt: timestampFromJson(json['updated_at'] as Timestamp));
}

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentID,
      'email': instance.email,
      'full_name': instance.fullName,
      'is_active': instance.isActive,
      'created_at': timestampToJson(instance.createdAt),
      'updated_at': timestampToJson(instance.updatedAt)
    };
