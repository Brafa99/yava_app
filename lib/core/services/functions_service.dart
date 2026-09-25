import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

/// Boundary for protected Cloud Functions operations.
///
/// Wallet writes, commissions, protected trip transitions, and administrative
/// workflows should be added here instead of being performed by the client.
class FunctionsService {
  final FirebaseBootstrapResult bootstrap;

  const FunctionsService(this.bootstrap);

  bool get isReady => bootstrap.isConfigured;
}

final functionsServiceProvider = Provider<FunctionsService>(
  (ref) => FunctionsService(ref.watch(firebaseBootstrapProvider)),
);