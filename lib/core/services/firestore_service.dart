import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

class FirestoreService {
  final FirebaseBootstrapResult bootstrap;

  FirestoreService(this.bootstrap);

  FirebaseFirestore? get instance {
    if (!bootstrap.isConfigured) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? collection(String path) {
    return instance?.collection(path);
  }

  Future<void> setDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final reference = collection(collectionPath);
    if (reference == null) return;
    await reference.doc(documentId).set(data, SetOptions(merge: true));
  }
}

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(ref.watch(firebaseBootstrapProvider)),
);