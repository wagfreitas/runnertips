import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LoginFooter extends StatelessWidget {
  final VoidCallback? onSignUpPressed;
  
  const LoginFooter({
    super.key,
    this.onSignUpPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            const TextSpan(text: "Não tem uma conta? "),
            WidgetSpan(
              child: GestureDetector(
                onTap: onSignUpPressed,
                child: Text(
                  'Cadastre-se',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
