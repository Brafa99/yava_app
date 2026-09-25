import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

class AuthService {
  final FirebaseBootstrapResult bootstrap;

  AuthService(this.bootstrap);

  FirebaseAuth? get _auth {
    if (!bootstrap.isConfigured) return null;
    return FirebaseAuth.instance;
  }

  User? get currentUser => _auth?.currentUser;

  Stream<User?> authStateChanges() {
    final auth = _auth;
    return auth == null ? Stream<User?>.value(null) : auth.authStateChanges();
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw const AuthException(
        'Firebase is not configured. Run flutterfire configure first.',
      );
    }
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> register({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw const AuthException(
        'Firebase is not configured. Run flutterfire configure first.',
      );
    }
    return auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth?.signOut();
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseBootstrapProvider)),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);