import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cria um novo usuário no Firebase Auth
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Atualiza o nome do usuário no Firebase Auth
  Future<void> updateUserDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Cria o documento do usuário no Firestore
  Future<void> createUserDocument(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toMap());
    } catch (e) {
      throw Exception('Erro ao criar documento do usuário: $e');
    }
  }

  /// Obtém o usuário atual do Firebase Auth
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Faz logout do usuário
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Trata exceções do Firebase Auth e retorna mensagens em português
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha fornecida é muito fraca.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este endereço de email.';
      case 'invalid-email':
        return 'O endereço de email fornecido não é válido.';
      case 'operation-not-allowed':
        return 'Esta operação não é permitida.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este email.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'As credenciais fornecidas são inválidas.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
