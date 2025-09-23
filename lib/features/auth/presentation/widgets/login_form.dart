import 'package:flutter/material.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/login_provider.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onForgotPasswordPressed;
  final LoginProvider authProvider;
  
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.authProvider,
    this.onLoginPressed,
    this.onForgotPasswordPressed,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_validateForm);
    widget.passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final email = widget.emailController.text.trim();
    final password = widget.passwordController.text.trim();
    
    setState(() {
      _isFormValid = email.isNotEmpty && 
                     email.contains('@') && 
                     password.isNotEmpty && 
                     password.length >= 6;
    });
  }

  void _handleLogin() {
    widget.onLoginPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authProvider,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de email
            AppTextField(
              controller: widget.emailController,
              hintText: 'Email ou Usuário',
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              prefixIcon: const AppTextFieldIcon(
                icon: Icons.mail_outline,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu email ou usuário';
                }
                if (!value.contains('@')) {
                  return 'Digite um email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo de senha
            AppTextField(
              controller: widget.passwordController,
              hintText: 'Senha',
              obscureText: _obscurePassword,
              textCapitalization: TextCapitalization.none,
              prefixIcon: const AppTextFieldIcon(
                icon: Icons.lock_outline,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              onSubmitted: (_) => _handleLogin(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite sua senha';
                }
                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Link "Forgot Password"
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onForgotPasswordPressed,
                child: Text(
                  'Esqueceu sua senha?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botão de login
            AppButton(
              text: 'Entrar',
              onPressed: _isFormValid && !widget.authProvider.isLoading ? _handleLogin : null,
              isLoading: widget.authProvider.isLoading,
              type: AppButtonType.primary,
              size: AppButtonSize.large,
            ),
          ],
        );
      },
    );
  }
}