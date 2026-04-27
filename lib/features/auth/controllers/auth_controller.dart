import 'dart:io';
import 'package:chat_app/features/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/providers/firebase_providers.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChange;
});

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  if (auth.currentUser == null) return Stream.value(null);
  return firestore
      .collection('users11')
      .doc(auth.currentUser!.uid)
      .snapshots()
      .map((event) => event.data() != null ? UserModel.fromMap(event.data()!) : null);
});


class AuthController {
  final AuthRepository authRepository;
  final Ref ref;

  AuthController({required this.authRepository, required this.ref});

  Future<void> signIn(String email, String password) async {
    await authRepository.signInWithEmail(email, password);
  }

  Future<void> signUp(String name, String email, String password) async {
    await authRepository.signUpWithEmail(name, email, password);
  }

  Future<void> signOut() async {
    await authRepository.signOut();
  }

  Future<void> updateProfile({
    required String name,
    required File? profilePicFile,
  }) async {
    await authRepository.updateProfile(
      name: name,
      profilePicFile: profilePicFile,
      ref: ref,
    );
  }
}
