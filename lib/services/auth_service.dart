// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of authenticated Firebase user
  Stream<User?> get user => _auth.authStateChanges();

  // ------------------------------
  // SIGN UP
  // ------------------------------
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // renter or landlord
  }) async {
    try {
      print('Creating user: $email');

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

      // Save user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Firestore write success');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Other sign up error: $e');
      rethrow;
    }
  }

  // ------------------------------
  // SIGN IN (returns role)
  // ------------------------------
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Logging in: $email');

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

        print('Login role: ${model.role}');
        return model.role;
      }

      // Default if user document is missing
      print('User doc missing. Default role: renter');
      return 'renter';
    } on FirebaseAuthException catch (e) {
      print('Sign in failed: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // ------------------------------
  // SIGN OUT
  // ------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
    print('Signed out');
  }

  // ------------------------------
  // PASSWORD RESET
  // ------------------------------
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print('Reset error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // ------------------------------
  // FETCH USER MODEL BY UID
  // ------------------------------
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }

      return null;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
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
      print('Error fetching current user model: $e');
      return null;
    }
  }
}
