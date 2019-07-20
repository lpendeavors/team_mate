import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_mate/data/user/firebase_user_repository.dart';
import 'package:team_mate/models/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseUserRepositoryImpl implements FirebaseUserRepository {
  final FirebaseAuth _firebaseAuth;
  final Firestore _firestore;
  final GoogleSignIn _googleSignIn;

  const FirebaseUserRepositoryImpl(
      this._firebaseAuth,
      this._firestore,
      this._googleSignIn,
  );

  @override
  Stream<UserEntity> user() {
    return Observable(_firebaseAuth.onAuthStateChanged)
        .switchMap((user) => _getUserByUid$(user?.uid));
  }

  Stream<UserEntity> _getUserByUid$(String uid) {
    if (uid == null) {
      return Observable.just(null);
    }
    return Observable(_firestore.document('users/$uid').snapshots()).map(
        (snapshot) => snapshot.exists ? UserEntity.fromDocumentSnapshot(snapshot) : null);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> signInWithEmailAndPassword({String email, String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
    );
  }

  @override
  Future<void> googleSignIn() async {
    final GoogleSignInAccount googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) {
      throw PlatformException(code: GoogleSignIn.kSignInCanceledError);
    }

    final GoogleSignInAuthentication googleAuth =
        await googleAccount.authentication;
    final FirebaseUser firebaseUser = await _firebaseAuth.signInWithCredential(
      GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
      ),
    );

    await _updateUserData(firebaseUser);
  }

  Future<void> _updateUserData(
      FirebaseUser user, [
      Map<String, dynamic> addition,
  ]) {
    final data = <String, dynamic>{
      'email': user.email,
      'full_name': user.displayName,
    };
    data.addAll(addition);
    print('[USER_REPO] _updateUserData data=$data');
    return _firestore.document('users/${user.uid}').setData(data, merge: true);
  }

  @override
  Future<void> registerWithEmail({
    @required String fullName,
    @required String email,
    @required String password
  }) async {
    if (fullName == null) return Future.error('fullname mull not be null');
    if (email == null) return Future.error('email must not be null');
    if (password == null) return Future.error('password must not be null');
    print(
      '[USER_REPO] registerWithEmail fullName=$fullName, email=$email, password=$password'
    );

    // create firebase auth user and update displayName
    var firebaseUser = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await firebaseUser.updateProfile(UserUpdateInfo()..displayName = fullName);
    // then save to firestore user info
    firebaseUser = await _firebaseAuth.currentUser();
    await _updateUserData(
      firebaseUser,
      <String, dynamic>{
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      },
    );
    print('[USER_REPO] registerWithEmail firebaseUser=$firebaseUser');

    print('[USER_REPO] registerWithEmail done');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    if (email == null) return Future.error('Email must no be null');
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Stream<UserEntity> getUserById({String uid}) => _getUserByUid$(uid);
}