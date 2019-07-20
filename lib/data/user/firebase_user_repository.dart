import 'dart:async';

import 'package:team_mate/models/user_entity.dart';
import 'package:meta/meta.dart';

abstract class FirebaseUserRepository {
  Stream<UserEntity> user();

  Future<void> signOut();

  Future<void> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  });

  Future<void> googleSignIn();

  Future<void> registerWithEmail({
    @required String fullName,
    @required String email,
    @required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Stream<UserEntity> getUserById({@required String uid});
}