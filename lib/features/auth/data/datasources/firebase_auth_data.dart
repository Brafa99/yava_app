import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'No se pudo crear el usuario.',
      );
    }

    await firebaseUser.updateDisplayName(fullName.trim());

    final userProfile = AppUser(
      uid: firebaseUser.uid,
      email: email.trim(),
      displayName: fullName.trim(),
      role: role,
      photoUrl: firebaseUser.photoURL,
    );

    await _usersCollection.doc(firebaseUser.uid).set(
      {
        'uid': userProfile.uid,
        'email': userProfile.email,
        'displayName': userProfile.displayName,
        'role': userProfile.role.value,
        'photoUrl': userProfile.photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return userProfile;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No se encontró el usuario autenticado.',
      );
    }

    final document =
        await _usersCollection.doc(firebaseUser.uid).get();

    if (!document.exists || document.data() == null) {
      throw FirebaseAuthException(
        code: 'profile-not-found',
        message: 'El perfil del usuario no existe.',
      );
    }

    final data = document.data()!;

    return AppUser(
      uid: firebaseUser.uid,
      email: data['email'] as String? ?? firebaseUser.email ?? '',
      displayName: data['displayName'] as String? ??
          firebaseUser.displayName ??
          'Usuario',
      role: UserRoleExtension.fromValue(
        data['role'] as String?,
      ),
      photoUrl: data['photoUrl'] as String? ??
          firebaseUser.photoURL,
    );
  }

  Stream<AppUser?> authStateChanges() {
  return _firebaseAuth.authStateChanges().asyncMap(
    (firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      final document = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      final data = document.data()!;

      return AppUser(
        uid: firebaseUser.uid,
        email: data['email'] as String? ??
            firebaseUser.email ??
            '',
        displayName: data['displayName'] as String? ??
            firebaseUser.displayName ??
            'Usuario',
        role: UserRoleExtension.fromValue(
          data['role'] as String?,
        ),
        photoUrl: data['photoUrl'] as String? ??
            firebaseUser.photoURL,
      );
    },
  );
}

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final document =
        await _usersCollection.doc(firebaseUser.uid).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    final data = document.data()!;

    return AppUser(
      uid: firebaseUser.uid,
      email: data['email'] as String? ?? firebaseUser.email ?? '',
      displayName: data['displayName'] as String? ??
          firebaseUser.displayName ??
          'Usuario',
      role: UserRoleExtension.fromValue(
        data['role'] as String?,
      ),
      photoUrl: data['photoUrl'] as String? ??
          firebaseUser.photoURL,
    );
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}