// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of authenticated Firebase user
  Stream<User?> get user => _auth.authStateChanges();

  // ------------------------------
  // SIGN UP (Matches the call from login_screen.dart)
  // ------------------------------
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // renter or landlord
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'USER_NULL',
          message: 'User creation failed: Firebase returned null.',
        );
      }

      // Save user data in Firestore (using DatabaseService for structure)
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // ------------------------------
  // SIGN IN (Matches the call from login_screen.dart)
  // ------------------------------
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'NO_USER_FOUND',
          message: 'Firebase returned null user.',
        );
      }

      // Fetch role from Firestore
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        UserModel model =
            UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        return model.role;
      }

      // Default if user document is missing
      return 'renter';
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ------------------------------
  // SIGN OUT
  // ------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ------------------------------
  // 🔑 NEW METHOD: GET CURRENT USER ID (Fixes dashboard errors)
  // ------------------------------
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // ------------------------------
  // PASSWORD RESET
  // ------------------------------
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ------------------------------
  // FETCH CURRENT LOGGED-IN USER MODEL
  // ------------------------------
  Future<UserModel?> getCurrentUserModel() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
