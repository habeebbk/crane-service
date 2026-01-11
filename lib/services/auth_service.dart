import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign In with Email and Password
  Future<User?> signIn(
      {required String email, required String password}) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow; // Re-throw the specific Firebase exception for caller to handle
    } catch (e) {
      // Catch any other unexpected errors and re-throw as a generic Exception
      throw Exception('An unexpected error occurred during sign-in: $e');
    }
  }

  // Sign Up with Email and Password
  Future<User?> signUp(
      {required String email, required String password}) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'unknown-error') {
        // Specific handling for a known Firebase internal error
        throw FirebaseAuthException(
          code: 'internal-error',
          message:
              'Internal Error: Please check if "Email/Password" Sign-in is enabled in Firebase Console.',
        );
      }
      rethrow; // Re-throw the specific Firebase exception for caller to handle
    } catch (e) {
      // Catch any other unexpected errors and re-throw as a generic Exception
      throw Exception('An unexpected error occurred during sign-up: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update Profile Display Name
  Future<void> updateDisplayName(String name) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
    } else {
      // If no user is logged in, throw an exception as display name cannot be updated.
      throw Exception('No user is currently signed in to update display name.');
    }
  }
}
