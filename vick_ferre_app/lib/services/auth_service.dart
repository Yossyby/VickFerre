import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔥 LOGIN CON GOOGLE (ACTUALIZADO)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // ✅ WEB (Chrome / Edge)
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider();

        return await _auth.signInWithPopup(authProvider);
      } 
      
      // ✅ ANDROID / IOS
      else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          // ⚠️ accessToken ya no siempre es necesario
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      print("Error en Google Sign-In: $e");
      return null;
    }
  }

  // 📧 LOGIN EMAIL
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print("Error en Email/Password Sign-In: $e");
      return null;
    }
  }

  // 🆕 REGISTRO
  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print("Error al crear cuenta: $e");
      return null;
    }
  }

  // 🚪 LOGOUT
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  // 🔑 RESET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error al enviar reset de contraseña: $e");
      rethrow; // Para que el llamador maneje el error
    }
  }
}