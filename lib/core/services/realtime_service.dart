import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

class RealtimeService {
  final FirebaseBootstrapResult bootstrap;

  RealtimeService(this.bootstrap);

  FirebaseDatabase? get database {
    if (!bootstrap.isConfigured) return null;
    return FirebaseDatabase.instance;
  }

  DatabaseReference? reference(String path) => database?.ref(path);

  Future<void> set(String path, Map<String, dynamic> value) async {
    await reference(path)?.set(value);
  }

  Stream<DatabaseEvent>? watch(String path) => reference(path)?.onValue;
}

class FirebaseDatabase {
}

final realtimeServiceProvider = Provider<RealtimeService>(
  (ref) => RealtimeService(ref.watch(firebaseBootstrapProvider)),
);