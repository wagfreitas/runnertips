import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/user_model.dart';

abstract class AuthRepository {
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> updateUserDisplayName(String name);

  Future<void> createUserDocument(UserModel userModel);

  User? getCurrentUser();

  Future<void> signOut();
}
