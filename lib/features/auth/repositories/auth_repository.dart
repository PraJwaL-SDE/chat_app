import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import 'dart:io';
import '../../../../core/repositories/cloudinary_repository.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
  );
});

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  Stream<User?> get authStateChange => auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    UserModel user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      profilePic: '',
      isOnline: true,
      lastSeen: DateTime.now(),
    );
    await firestore.collection('users11').doc(user.uid).set(user.toMap());
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> updateProfile({
    required String name,
    required File? profilePicFile,
    required Ref ref,
  }) async {
    try {
      String profilePic = '';
      final currentUserId = auth.currentUser!.uid;

      if (profilePicFile != null) {
        profilePic = await ref.read(cloudinaryRepositoryProvider).uploadFile(
              profilePicFile,
              'profile_pics/$currentUserId',
            );
      }

      Map<String, dynamic> updateData = {'name': name};
      if (profilePic.isNotEmpty) {
        updateData['profilePic'] = profilePic;
      }

      await firestore.collection('users11').doc(currentUserId).update(updateData);
    } catch (e) {
      throw e.toString();
    }
  }
}
