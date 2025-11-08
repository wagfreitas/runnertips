import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
<<<<<<< HEAD
import '../../features/race/presentation/pages/races_screen.dart';
=======
import '../../features/home/presentation/pages/home_screen.dart';
>>>>>>> 210d463 (feat: login, pesquisa prontos)

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    await _sessionService.initialize();
  }

  @override
  void dispose() {
    _sessionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _sessionService,
      builder: (context, child) {
        // Mostra loading enquanto verifica a sessão
        if (_sessionService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Se está logado, vai para a tela principal
        if (_sessionService.isLoggedIn) {
<<<<<<< HEAD
          return const RacesScreen();
=======
          return const HomeScreen();
>>>>>>> 210d463 (feat: login, pesquisa prontos)
        }

        // Se não está logado, vai para a tela de login
        return const LoginScreen();
      },
    );
  }
}
