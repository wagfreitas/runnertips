import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/models/user_model.dart';

class LoginProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Faz login do usuário
  Future<LoginResult> loginUser({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    clearMessages();

    try {
      final result = await _authService.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        _successMessage = 'Login realizado com sucesso!';
        
        // Atualiza o SessionService
        await _sessionService.login(result.user!, result.token!);
        
        _setLoading(false);
        return LoginResult.success(result.user!);
      } else {
        _errorMessage = result.message ?? 'Erro ao fazer login';
        _setLoading(false);
        return LoginResult.failure(_errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _setLoading(false);
      return LoginResult.failure(_errorMessage!);
    }
  }

  /// Verifica se o usuário está logado
  Future<bool> isUserLoggedIn() async {
    return await _authService.isUserLoggedIn();
  }

  /// Recupera usuário atual
  Future<UserModel?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  /// Faz logout do usuário
  Future<void> logout() async {
    await _authService.logout();
    clearMessages();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

/// Resultado da operação de login
class LoginResult {
  final bool isSuccess;
  final String? message;
  final UserModel? user;

  LoginResult._({
    required this.isSuccess,
    this.message,
    this.user,
  });

  factory LoginResult.success(UserModel user) {
    return LoginResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory LoginResult.failure(String message) {
    return LoginResult._(
      isSuccess: false,
      message: message,
    );
  }
}
