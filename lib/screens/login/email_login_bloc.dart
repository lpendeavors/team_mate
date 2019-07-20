import 'dart:async';

import 'package:team_mate/bloc/bloc_provider.dart';
import 'package:team_mate/data/user/firebase_user_repository.dart';
import 'package:team_mate/screens/login/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

bool _isValidPassword(String password) {
  return password.length >= 6;
}

bool _isValidEmail(String email) {
  final _emailRegExpString = r'[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9]'
      'r[a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0.25})+';
  return RegExp(_emailRegExpString, caseSensitive: false).hasMatch(email);
}

///
/// Bloc handling sign in with email and password
///
class EmailLoginBloc implements BaseBloc {
  ///
  /// Input Functions
  ///
  final void Function() submitLogin;
  final void Function(String) emailChanged;
  final void Function(String) passwordChanged;

  ///
  /// Output Streams
  ///
  final ValueObservable<bool> isLoading$;
  final Stream<LoginMessage> message$;
  final Stream<EmailError> emailError$;
  final Stream<PasswordError> passwordError$;

  ///
  /// Clean up
  ///
  final void Function() _dispose;

  EmailLoginBloc._({
    @required this.emailChanged,
    @required this.passwordChanged,
    @required this.submitLogin,
    @required this.isLoading$,
    @required this.message$,
    @required this.emailError$,
    @required this.passwordError$,
    @required void Function() dispose,
  }) : _dispose = dispose;

  @override
  void dispose() => _dispose();

  factory EmailLoginBloc(FirebaseUserRepository userRepository) {
    ///
    /// Assert
    ///
    assert(userRepository != null, 'userRepository cannot be null');

    ///
    /// Controllers
    ///

    // ignore: close_sinks
    final emailController = BehaviorSubject<String>.seeded('');
    // ignore: close_sinks
    final passwordController = BehaviorSubject<String>.seeded('');
    // ignore: close_sinks
    final submitLoginController = PublishSubject<void>();
    final isLoadingController = BehaviorSubject<bool>.seeded(false);

    ///
    /// Streams
    ///

    final emailError$ = emailController.stream.map<EmailError>((email) {
      if (_isValidEmail(email)) return null;
      return const InvalidEmailAddress();
    });

    final passwordError$ = passwordController.stream.map<PasswordError>((password) {
      if (_isValidPassword(password)) return null;
      return const PasswordAtLeast6Characters();
    });

    final isValid$ = Observable.combineLatest3(
      emailError$,
      passwordError$,
      isLoadingController.stream,
      (emailError, passwordError, isLoading) =>
          emailError == null && passwordError == null && !isLoading
    );

    final emailAndPassword$ = Observable.combineLatest2(
      emailController.stream,
      passwordController.stream,
      (String email, String password) => Tuple2(email, password)
    );

    final message$ = submitLoginController
      .withLatestFrom(isValid$, (_, bool isValid) => isValid)
      .where((isValid) => isValid)
      .withLatestFrom(emailAndPassword$,
        (_, Tuple2<String, String> emailAndPassword) => emailAndPassword)
      .switchMap((emailAndPassword) => performLogin(
        emailAndPassword.item1,
        emailAndPassword.item2,
        userRepository,
        isLoadingController,
      )).publish();

    ///
    /// Subscriptions and controllers
    ///

    final subscriptions = <StreamSubscription>[
      message$.connect(),
    ];

    final controllers = <StreamController>[
      isLoadingController,
      emailController,
      passwordController,
      submitLoginController,
    ];

    ///
    /// Return BLoC
    ///
    return EmailLoginBloc._(
      emailChanged: emailController.add,
      passwordChanged: passwordController.add,
      submitLogin: () => submitLoginController.add(null),
      isLoading$: isLoadingController.stream,
      message$: message$,
      dispose: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await Future.wait(controllers.map((c) => c.close()));
      },
      passwordError$: passwordError$,
      emailError$: emailError$,
    );
  }

  static Stream<LoginMessage> performLogin(
    String email,
    String password,
    FirebaseUserRepository userRepository,
    Sink<bool> isLoadingController,
  ) async* {
    print('[DEBUG] performLogin');
    try {
      isLoadingController.add(true);
      await userRepository.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      yield const LoginMessageSuccess();
    } catch (e) {
      yield _getLoginError(e);
    } finally {
      isLoadingController.add(false);
    }
  }

  static LoginMessageError _getLoginError(error) {
    if (error is PlatformException) {
      switch (error.code) {
        case 'ERROR_INVALID_EMAIL':
          return const LoginMessageError(InvalidEmailError());
        case 'ERROR_WRONG_PASSWORD':
          return const LoginMessageError(WrongPasswordError());
        case 'ERROR_EMAIL_ALREADY_IN_USE':
          return const LoginMessageError(EmailAlreadyInUserError());
        case 'ERROR_USER_DISABLED':
          return const LoginMessageError(UserDisabledError());
        case 'ERROR_USER_NOT_FOUND':
          return const LoginMessageError(UserNotFoundError());
        case 'ERROR_WEAK_PASSWORD':
          return const LoginMessageError(WeakPasswordError());
        case 'ERROR_NETWORK_REQUEST_FAILED':
          return const LoginMessageError(NetworkError());
        case 'ERROR_TOO_MANY_REQUESTS':
          return const LoginMessageError(TooManyRequestsError());
        case 'ERROR_OPERATION_NOT_ALLOWED':
          return const LoginMessageError(OperationNotAllowedError());
      }
    }
    return LoginMessageError(UnknownError(error));
  }
}