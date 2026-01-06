import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zoom_clone/utils/utils.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User get user => _auth.currentUser!;

  Future<bool> signInWithGoogle(BuildContext context) async {
    final googleSignIn = GoogleSignIn.instance;

    try {
      await googleSignIn.initialize();

      if (!googleSignIn.supportsAuthenticate()) {
        showSnackBar(context, "Google Sign-In not supported");
        return false;
      }

      // IMPORTANT: set listener BEFORE authenticate
      final authEventFuture = googleSignIn.authenticationEvents.first;

      try {
        await googleSignIn.authenticate(scopeHint: ['email', 'profile']);
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          // User backed out — NOT an error
          debugPrint("Google sign-in canceled by user");
          return false;
        }
        rethrow;
      }

      final event = await authEventFuture;

      if (event is! GoogleSignInAuthenticationEventSignIn) {
        return false;
      }

      final googleUser = event.user;
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'username': firebaseUser.displayName,
          'uid': firebaseUser.uid,
          'profilePhoto': firebaseUser.photoURL,
        });
      }

      return true;
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message ?? "Firebase auth error");
      return false;
    } on GoogleSignInException catch (e) {
      showSnackBar(context, "Google sign-in error: ${e.description}");
      return false;
    } catch (e) {
      showSnackBar(context, e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.disconnect();
  }
}
