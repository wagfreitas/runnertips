import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../models/user_model.dart';

class SessionService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  /// Inicializa o serviço de sessão
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      // Verifica se o usuário está logado
      _isLoggedIn = await _authService.isUserLoggedIn();
      
      if (_isLoggedIn) {
        // Recupera dados do usuário
        _currentUser = await _authService.getCurrentUser();
      } else {
        _currentUser = null;
      }
    } catch (e) {
      // Em caso de erro, assume que não está logado
      print('Erro ao inicializar sessão: $e');
      _isLoggedIn = false;
      _currentUser = null;
    }
    
    _setLoading(false);
  }

  /// Faz login do usuário
  Future<bool> login(UserModel user, String token) async {
    try {
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Faz logout do usuário
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      // Log do erro, mas continua com o logout
      print('Erro ao fazer logout: $e');
    }
  }

  /// Atualiza dados do usuário
  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
