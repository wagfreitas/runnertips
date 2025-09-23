import 'package:firebase_auth/firebase_auth.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> updateUserDisplayName(String name) async {
    return await _remoteDataSource.updateUserDisplayName(name);
  }

  @override
  Future<void> createUserDocument(UserModel userModel) async {
    return await _remoteDataSource.createUserDocument(userModel);
  }

  @override
  User? getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> signOut() async {
    return await _remoteDataSource.signOut();
  }
}
