import 'package:flutter/material.dart';
import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/services/register_user_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/utils/password_validator.dart';

class AuthProvider extends ChangeNotifier {
  final RegisterUserService _registerUserService;
  
  // Estados
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get currentUser => _currentUser;

  AuthProvider({
    required RegisterUserService registerUserService,
  }) : _registerUserService = registerUserService;

  /// Limpa as mensagens
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Define o estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define mensagem de erro
  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  /// Define mensagem de sucesso
  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  /// Registra um novo usuário
  Future<RegisterResult> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String experience,
  }) async {
    _clearMessages();
    _setLoading(true);

    try {
      // 1. Validar senha
      final passwordValidation = PasswordValidator.validateCompletePassword(
        password,
        confirmPassword,
      );

      if (!passwordValidation.isValid) {
        _setError(passwordValidation.message);
        _setLoading(false);
        return RegisterResult(
          success: false,
          message: passwordValidation.message,
        );
      }

      // 2. Registrar usuário
      final result = await _registerUserService(
        name: name,
        email: email,
        password: password,
        experience: experience,
      );

      if (result.success) {
        _currentUser = result.user;
        _setSuccess(result.message);
      } else {
        _setError(result.message);
      }

      _setLoading(false);
      return result;
    } catch (e) {
      _setError('Erro inesperado: $e');
      _setLoading(false);
      return RegisterResult(
        success: false,
        message: 'Erro inesperado: $e',
      );
    }
  }

  /// Limpa as mensagens manualmente
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  /// Faz logout
  Future<void> signOut() async {
    _clearMessages();
    _setLoading(true);

    try {
      final authRepository = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSource(),
      );
      
      await authRepository.signOut();
      _currentUser = null;
      _setSuccess('Logout realizado com sucesso');
    } catch (e) {
      _setError('Erro ao fazer logout: $e');
    } finally {
      _setLoading(false);
    }
  }
}

/// Factory para criar o AuthProvider com todas as dependências
class AuthProviderFactory {
  static AuthProvider create() {
    final authDataSource = AuthRemoteDataSource();
    final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);
    final registerService = RegisterUserService(authRepository: authRepository);
    
    return AuthProvider(registerUserService: registerService);
  }
}
