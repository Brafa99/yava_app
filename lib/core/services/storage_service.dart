import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_bootstrap.dart';

class StorageService {
  final FirebaseBootstrapResult bootstrap;

  StorageService(this.bootstrap);

  FirebaseStorage? get storage {
    if (!bootstrap.isConfigured) return null;
    return FirebaseStorage.instance;
  }

  Future<String?> uploadBytes({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final reference = storage?.ref(path);
    if (reference == null) return null;
    final snapshot = await reference.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return snapshot.ref.fullPath;
  }
}

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.watch(firebaseBootstrapProvider)),
);