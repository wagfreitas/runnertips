import 'package:flutter/material.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/login_footer.dart';
import '../providers/login_provider.dart';
import 'register_screen.dart';
import '../../../race/presentation/pages/races_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginProvider _loginProvider;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loginProvider = LoginProvider();
  }

  @override
  void dispose() {
    _loginProvider.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await _loginProvider.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.isSuccess && mounted) {
        // Navigate to races screen with slide animation
        Navigator.of(context).pushReplacement(
          AppAnimations.createSlideRoute(
            const RacesScreen(),
            begin: const Offset(1.0, 0.0),
            duration: const Duration(milliseconds: 350),
          ),
        );
      }
    }
  }

  void _handleForgotPassword() {
    // Navigate to forgot password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento'),
      ),
    );
  }

  void _handleSignUp() {
    // Navigate to register screen with animation
    Navigator.of(context).push(
      AppAnimations.createSlideRoute(
        const RegisterScreen(),
        begin: const Offset(1.0, 0.0),
        duration: const Duration(milliseconds: 350),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Cabeçalho da tela
                const LoginHeader(),
                
                // Formulário de login
                Form(
                  key: _formKey,
                  child: LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onLoginPressed: _handleLogin,
                    onForgotPasswordPressed: _handleForgotPassword,
                    authProvider: _loginProvider,
                  ),
                ),
                
                // Mensagens de erro e sucesso
                ListenableBuilder(
                  listenable: _loginProvider,
                  builder: (context, child) {
                    if (_loginProvider.errorMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _loginProvider.errorMessage!,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (_loginProvider.successMessage != null) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _loginProvider.successMessage!,
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Rodapé da tela
                LoginFooter(
                  onSignUpPressed: _handleSignUp,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}