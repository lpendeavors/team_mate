import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/models/firebase_model.dart';
import 'package:team_mate/util/model_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'user_entity.g.dart';

@immutable
@JsonSerializable()
class UserEntity implements FirebaseModel {
  @JsonKey(name: 'documentId')
  final String documentID;

  final String email;

  @JsonKey(name: 'full_name')
  final String fullName;

  @JsonKey(name: 'is_active')
  final bool isActive;

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

  const UserEntity({
    this.documentID,
    this.email,
    this.fullName,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String get id => this.documentID;

  factory UserEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$UserEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  String toString() => 'UserEntity{documentID: $documentID, email: $email, fullname: $fullName, '
      ' isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          documentID == other.documentID &&
          email == other.email &&
          fullName == other.fullName &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      documentID.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}