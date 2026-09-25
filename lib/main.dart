import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/firebase_bootstrap.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  late FirebaseBootstrapResult bootstrap;
  try {
    bootstrap = await FirebaseBootstrap.initialize(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    bootstrap = FirebaseBootstrapResult(isConfigured: false, error: error);
  }

  runApp(
    ProviderScope(
      overrides: [
        firebaseBootstrapProvider.overrideWithValue(bootstrap),
      ],
      child: const YavaDeliveryApp(),
    ),
  );
}