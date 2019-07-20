import 'dart:async';

import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/user/firebase_user_repository.dart';
import 'package:team_mate/models/user_entity.dart';
import 'package:team_mate/user_bloc/user_login_state.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc implements BaseBloc {
  ///
  /// Sinks
  ///
  final Sink<void> signOut;

  ///
  /// Streams
  ///
  final ValueObservable<LoginState> loginState$;
  final Stream<UserMessage> message$;

  /// Cleanup
  final void Function() _dispose;

  factory UserBloc(FirebaseUserRepository userRepository) {
    final signOutController = PublishSubject<void>(sync: true);

    final user$ = Observable(userRepository.user())
      .map(_toLoginState)
      .distinct()
      .publishValueSeeded(const Unauthenticated());

    final signOutMessage$ = signOutController.exhaustMap((_) {
      return Observable.fromFuture(userRepository.signOut())
          .doOnError((e) => print('[DEBUG logout error=$e'))
          .onErrorReturnWith((e) => UserLogoutMessageError(e))
          .map((_) => const UserLogoutMessageSuccess());
    }).publish();

    final subscriptions = <StreamSubscription<dynamic>>[
      user$.connect(),
      signOutMessage$.connect(),
    ];

    return UserBloc._(
      () {
        signOutController.close();
        subscriptions.forEach((subscription) => subscription.cancel());
      },
      user$,
      signOutController.sink,
      signOutMessage$,
    );
  }

  UserBloc._(
    this._dispose,
    this.loginState$,
    this.signOut,
    this.message$,
  );

  @override
  void dispose() => _dispose();

  static LoginState _toLoginState(UserEntity userEntity) {
    if (userEntity == null) {
      return const Unauthenticated();
    }
    return LoggedInUser(
      fullName: userEntity.fullName,
      email: userEntity.email,
      uid: userEntity.id,
      isActive: userEntity.isActive,
      createdAt: userEntity.createdAt.toDate(),
      updatedAt: userEntity.updatedAt.toDate(),
    );
  }
}