// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NoGoogleAccountChosenException implements Exception {
  const NoGoogleAccountChosenException();
}

class AuthService {
  AuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  static User? get user => _auth.currentUser;
  static Stream<User?> get userStream => _auth.userChanges();
  static bool get isEmailVerified => user?.emailVerified ?? false;

  static Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await credential.user?.updateDisplayName(fullName);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

 static Future<UserCredential> signInWithGoogle() async {
  try {
    // For older google_sign_in versions
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      throw const NoGoogleAccountChosenException();
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  } catch (e) {
    rethrow;
  }
}

  static Future<void> resetPassword({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}