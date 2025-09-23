import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/register_header.dart';
import '../widgets/register_form.dart';
import '../widgets/register_footer.dart';
import '../providers/auth_provider.dart';
import '../../../race/presentation/pages/races_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProviderFactory.create();
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  void _handleRegisterSuccess() {
    // Navegar para a tela inicial do sistema (races_screen)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const RacesScreen(),
      ),
    );
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  void _handleSignIn() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cabeçalho com botão de voltar
              RegisterHeader(
                onBackPressed: _handleBack,
              ),
              
              // Formulário de registro
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RegisterForm(
                  authProvider: _authProvider,
                  onRegisterSuccess: _handleRegisterSuccess,
                ),
              ),
              
              // Rodapé com link para login
              RegisterFooter(
                onSignInPressed: _handleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
