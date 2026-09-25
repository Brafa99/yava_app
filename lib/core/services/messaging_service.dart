import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

class MessagingService {
  final FirebaseBootstrapResult bootstrap;

  MessagingService(this.bootstrap);

  FirebaseMessaging? get messaging {
    if (!bootstrap.isConfigured) return null;
    return FirebaseMessaging.instance;
  }

  Future<String?> requestToken() async {
    final instance = messaging;
    if (instance == null) return null;
    await instance.requestPermission();
    return instance.getToken();
  }
}


final messagingServiceProvider = Provider<MessagingService>(
  (ref) => MessagingService(ref.watch(firebaseBootstrapProvider)),
);