import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseBootstrapResult {
  final bool isConfigured;
  final Object? error;

  const FirebaseBootstrapResult({
    required this.isConfigured,
    this.error,
  });
}

class FirebaseBootstrap {
  static Future<FirebaseBootstrapResult> initialize({
    required FirebaseOptions options,
  }) async {
    try {
      await Firebase.initializeApp(options: options);
      return const FirebaseBootstrapResult(isConfigured: true);
    } catch (error) {
      return FirebaseBootstrapResult(isConfigured: false, error: error);
    }
  }
}

final firebaseBootstrapProvider = Provider<FirebaseBootstrapResult>(
  (ref) => const FirebaseBootstrapResult(isConfigured: false),
);