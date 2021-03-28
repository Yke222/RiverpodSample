import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_sample/repositories/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController>(
  (ref) => AuthController(ref.read)..appStarted(),
);

class AuthController extends StateNotifier<User?> {
  AuthController(this._read) : super(null) {
    _authStateChangeSubscription?.cancel();
    _authStateChangeSubscription = _read(authRepositoryProvider)
        .authStateChanges
        .listen((user) => state = user);
  }

  final Reader _read;

  StreamSubscription<User?>? _authStateChangeSubscription;

  @override
  void dispose() {
    _authStateChangeSubscription?.cancel();
    super.dispose();
  }

  void appStarted() async {
    final user = _read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      await _read(authRepositoryProvider).signInAnonymously();
    }
  }

  void signOut() async {
    await _read(authRepositoryProvider).signOut();
  }
}
