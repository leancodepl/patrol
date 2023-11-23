import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthStateLoading());

  late final _firebaseAuth = FirebaseAuth.instance;
  late final _googleSignIn = GoogleSignIn();
  late final StreamSubscription<User?> _authStateChangesSubscription;

  void init() {
    final user = _firebaseAuth.currentUser;
    _emitAuthState(user);

    _authStateChangesSubscription =
        _firebaseAuth.authStateChanges().listen(_emitAuthState);
  }

  void _emitAuthState(User? user) {
    if (user == null) {
      emit(AuthStateUnauthenticated());
    } else {
      emit(AuthStateAuthenticated(user));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthStateLoading());
    try {
      final googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      emit(AuthStateUnauthenticated(showError: true));
      emit(AuthStateUnauthenticated());
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> close() {
    _authStateChangesSubscription.cancel();
    return super.close();
  }
}

@immutable
sealed class AuthState {}

final class AuthStateLoading extends AuthState {}

final class AuthStateAuthenticated extends AuthState {
  AuthStateAuthenticated(this.user);

  final User user;
}

final class AuthStateUnauthenticated extends AuthState {
  AuthStateUnauthenticated({this.showError = false});

  final bool showError;
}
