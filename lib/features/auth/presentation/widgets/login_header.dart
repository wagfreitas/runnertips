import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo da aplicação
        SvgPicture.asset(
          AppAssets.logoApp,
          width: 95,
          height: 95,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryOrange,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 20),
        
        // Título
        Text(
          'Bem vindo a comunidade Runner Tips',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Subtítulo
        Text(
          'Faça login para continuar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}