import 'package:flutter/material.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/password_validator.dart';
import '../providers/auth_provider.dart';

class RegisterForm extends StatefulWidget {
  final AuthProvider authProvider;
  final VoidCallback? onRegisterSuccess;
  
  const RegisterForm({
    super.key,
    required this.authProvider,
    this.onRegisterSuccess,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedExperience = '';

  final List<Map<String, String>> _experienceOptions = [
    {'value': '', 'label': 'Selecione sua experiência'},
    {'value': 'beginner', 'label': 'Iniciante (0-1 anos)'},
    {'value': 'intermediate', 'label': 'Intermediário (1-3 anos)'},
    {'value': 'advanced', 'label': 'Avançado (3-5 anos)'},
    {'value': 'expert', 'label': 'Expert (5+ anos)'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await widget.authProvider.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        experience: _selectedExperience,
      );

      if (result.success) {
        widget.onRegisterSuccess?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mensagens de erro e sucesso
          ListenableBuilder(
            listenable: widget.authProvider,
            builder: (context, child) {
              if (widget.authProvider.errorMessage != null) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
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
                          widget.authProvider.errorMessage!,
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
              
              if (widget.authProvider.successMessage != null) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
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
                          widget.authProvider.successMessage!,
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
          // Campo Nome Completo
          AppTextField(
            controller: _nameController,
            label: 'Nome Completo',
            hintText: 'João Silva',
            prefixIcon: const AppTextFieldIcon(
              icon: Icons.person_outline,
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu nome completo';
              }
              if (value.trim().split(' ').length < 2) {
                return 'Por favor, digite seu nome e sobrenome';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Campo Email
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'voce@exemplo.com',
            prefixIcon: const AppTextFieldIcon(
              icon: Icons.mail_outline,
            ),
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite seu email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Por favor, digite um email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Campo Senha
          AppTextField(
            controller: _passwordController,
            label: 'Senha',
            hintText: '••••••••',
            prefixIcon: const AppTextFieldIcon(
              icon: Icons.lock_outline,
            ),
            obscureText: _obscurePassword,
            textCapitalization: TextCapitalization.none,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, digite sua senha';
              }
              
              final passwordValidation = PasswordValidator.validatePassword(value);
              if (!passwordValidation.isValid) {
                return passwordValidation.message;
              }
              
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Campo Confirmar Senha
          AppTextField(
            controller: _confirmPasswordController,
            label: 'Confirmar Senha',
            hintText: '••••••••',
            prefixIcon: const AppTextFieldIcon(
              icon: Icons.lock_reset,
            ),
            obscureText: _obscureConfirmPassword,
            textCapitalization: TextCapitalization.none,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, confirme sua senha';
              }
              
              final confirmationValidation = PasswordValidator.validatePasswordConfirmation(
                _passwordController.text,
                value,
              );
              
              if (!confirmationValidation.isValid) {
                return confirmationValidation.message;
              }
              
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Campo Experiência (Dropdown)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experiência na Corrida (Opcional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedExperience.isEmpty ? null : _selectedExperience,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        Icons.directions_run,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  hint: Text(
                    'Selecione sua experiência',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  items: _experienceOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(
                        option['label']!,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExperience = value ?? '';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Botão de registro
          ListenableBuilder(
            listenable: widget.authProvider,
            builder: (context, child) {
              return AppButton(
                text: 'Criar Conta',
                onPressed: _handleRegister,
                isLoading: widget.authProvider.isLoading,
                type: AppButtonType.primary,
                size: AppButtonSize.large,
              );
            },
          ),
        ],
      ),
    );
  }
}
