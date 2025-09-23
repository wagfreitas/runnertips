import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Faz login do usuário com email e senha
  Future<AuthResult> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Autentica com Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('Erro ao fazer login. Tente novamente.');
      }

      // Busca dados do usuário no Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return AuthResult.failure('Usuário não encontrado no sistema.');
      }

      final UserModel userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      // Gera JWT token
      final String token = await _generateJWTToken(userModel);

      // Salva dados no localStorage
      await _saveUserSession(userModel, token);

      return AuthResult.success(userModel, token);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          message = 'Senha incorreta.';
          break;
        case 'invalid-email':
          message = 'Email inválido.';
          break;
        case 'user-disabled':
          message = 'Usuário desabilitado.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        default:
          message = 'Erro ao fazer login: ${e.message}';
      }
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('Erro inesperado: ${e.toString()}');
    }
  }

  /// Gera um token JWT simples (em produção, use uma biblioteca JWT)
  Future<String> _generateJWTToken(UserModel user) async {
    final Map<String, dynamic> payload = {
      'userId': user.id,
      'email': user.email,
      'name': user.name,
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
    };

    // Em produção, use uma biblioteca JWT real
    return base64Encode(utf8.encode(jsonEncode(payload)));
  }

  /// Salva sessão do usuário no localStorage
  Future<void> _saveUserSession(UserModel user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toMap()));
    } catch (e) {
      // Se shared_preferences falhar, apenas loga o erro mas não falha o login
      print('Erro ao salvar sessão: $e');
    }
  }

  /// Verifica se o usuário está logado
  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token == null) return false;

      // Verifica se o token ainda é válido
      final Map<String, dynamic> payload = jsonDecode(
        utf8.decode(base64Decode(token))
      );
      
      final int exp = payload['exp'] as int;
      final int now = DateTime.now().millisecondsSinceEpoch;
      
      if (now > exp) {
        await logout(); // Token expirado
        return false;
      }
      
      return true;
    } catch (e) {
      // Se houver erro com shared_preferences, considera como não logado
      print('Erro ao verificar sessão: $e');
      return false;
    }
  }

  /// Recupera dados do usuário logado
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson == null) return null;
      
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromMap(userMap);
    } catch (e) {
      print('Erro ao recuperar usuário: $e');
      return null;
    }
  }

  /// Faz logout do usuário
  Future<void> logout() async {
    try {
      // Faz logout do Firebase
      await _auth.signOut();
      
      // Remove dados do localStorage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      // Log do erro, mas não falha o logout
      print('Erro ao fazer logout: $e');
    }
  }

  /// Recupera token atual
  Future<String?> getCurrentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Erro ao recuperar token: $e');
      return null;
    }
  }
}

/// Resultado da operação de autenticação
class AuthResult {
  final bool isSuccess;
  final String? message;
  final UserModel? user;
  final String? token;

  AuthResult._({
    required this.isSuccess,
    this.message,
    this.user,
    this.token,
  });

  factory AuthResult.success(UserModel user, String token) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}
