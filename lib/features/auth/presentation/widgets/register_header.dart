import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegisterHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  
  const RegisterHeader({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Botão de voltar
          IconButton(
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
          ),
          
          // Título centralizado
          Expanded(
            child: Text(
              'Criar Conta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Espaçamento para centralizar o título
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
