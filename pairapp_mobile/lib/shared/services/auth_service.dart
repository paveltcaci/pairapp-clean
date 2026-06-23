import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around [FirebaseAuth] that exposes only what the app needs.
class AuthService {
  AuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // ── Reactive state ────────────────────────────────────────────────────────

  /// Emits the current [User] whenever auth state changes (sign-in / sign-out).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// The synchronously available current user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  // ── Auth actions ──────────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() => _auth.signOut();
}
