import 'package:flutter/material.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

class SocialLogin extends StatelessWidget {
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onAppleLogin;
  final VoidCallback? onFacebookLogin;
  
  const SocialLogin({
    super.key,
    this.onGoogleLogin,
    this.onAppleLogin,
    this.onFacebookLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divisor "OR"
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9CA3AF), // Gray-400
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        
        // Botões de login social
        Column(
          children: [
            // Google Login
            if (onGoogleLogin != null)
              AppButton(
                text: 'Continue with Google',
                onPressed: onGoogleLogin,
                type: AppButtonType.outlined,
                size: AppButtonSize.large,
                icon: const Icon(Icons.login), // Substituir por ícone do Google
              ),
            
            if (onGoogleLogin != null && onAppleLogin != null)
              const SizedBox(height: 12),
            
            // Apple Login
            if (onAppleLogin != null)
              AppButton(
                text: 'Continue with Apple',
                onPressed: onAppleLogin,
                type: AppButtonType.outlined,
                size: AppButtonSize.large,
                icon: const Icon(Icons.apple), // Substituir por ícone da Apple
              ),
            
            if ((onGoogleLogin != null || onAppleLogin != null) && onFacebookLogin != null)
              const SizedBox(height: 12),
            
            // Facebook Login
            if (onFacebookLogin != null)
              AppButton(
                text: 'Continue with Facebook',
                onPressed: onFacebookLogin,
                type: AppButtonType.outlined,
                size: AppButtonSize.large,
                icon: const Icon(Icons.facebook), // Substituir por ícone do Facebook
              ),
          ],
        ),
      ],
    );
  }
}
