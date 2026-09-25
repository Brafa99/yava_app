// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../repositories/repository_interfaces.dart';
// import '../services/auth_service.dart';
// import '../services/firestore_service.dart';
// import '../services/onboarding_service.dart';
// import '../../shared/models/domain_models.dart';

// final userRepositoryProvider = Provider<UserRepository>(
//   (ref) => FirestoreUserRepository(ref.watch(firestoreServiceProvider)),
// );

// final authRepositoryProvider = Provider<AuthRepository>(
//   (ref) => FirebaseAuthRepository(
//     ref.watch(authServiceProvider),
//     ref.watch(userRepositoryProvider),
//   ),
// );

// final currentUserProvider = Provider(
//   (ref) => ref.watch(authServiceProvider).currentUser,
// );

// final currentRoleProvider = FutureProvider<UserRole?>((ref) async {
//   final user = ref.watch(currentUserProvider);
//   if (user == null) return null;
//   final profile = await ref.watch(userRepositoryProvider).getProfile(user.uid);
//   return profile?.role;
// });

// final selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

// final onboardingCompletedProvider = FutureProvider<bool>(
//   (ref) => ref.watch(onboardingServiceProvider).hasCompleted(),
// );