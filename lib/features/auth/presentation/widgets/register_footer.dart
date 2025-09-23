import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegisterFooter extends StatelessWidget {
  final VoidCallback? onSignInPressed;
  
  const RegisterFooter({
    super.key,
    this.onSignInPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            const TextSpan(text: 'Já tem uma conta? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: onSignInPressed,
                child: Text(
                  'Entrar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
