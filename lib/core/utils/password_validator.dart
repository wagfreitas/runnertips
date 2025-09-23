class PasswordValidator {
  static const int minLength = 8;
  static const int maxLength = 50;

  /// Valida se a senha é forte o suficiente
  static PasswordValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return PasswordValidationResult(
        isValid: false,
        message: 'A senha é obrigatória',
      );
    }

    if (password.length < minLength) {
      return PasswordValidationResult(
        isValid: false,
        message: 'A senha deve ter pelo menos $minLength caracteres',
      );
    }

    if (password.length > maxLength) {
      return PasswordValidationResult(
        isValid: false,
        message: 'A senha deve ter no máximo $maxLength caracteres',
      );
    }

    // Verifica se contém pelo menos uma letra minúscula
    if (!password.contains(RegExp(r'[a-z]'))) {
      return PasswordValidationResult(
        isValid: false,
        message: 'A senha deve conter pelo menos uma letra minúscula',
      );
    }

    // Verifica se contém pelo menos uma letra maiúscula
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return PasswordValidationResult(
        isValid: false,
        message: 'A senha deve conter pelo menos uma letra maiúscula',
      );
    }

    // Verifica se contém pelo menos um número
    if (!password.contains(RegExp(r'[0-9]'))) {
      return PasswordValidationResult(
        isValid: false,
        message: 'A senha deve conter pelo menos um número',
      );
    }

    // Verifica se contém pelo menos um caractere especial
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return PasswordValidationResult(
        isValid: false,
        message: 'A senha deve conter pelo menos um caractere especial (!@#\$%^&*...)',
      );
    }

    return PasswordValidationResult(
      isValid: true,
      message: 'Senha válida',
    );
  }

  /// Valida se as duas senhas coincidem
  static PasswordValidationResult validatePasswordConfirmation(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return PasswordValidationResult(
        isValid: false,
        message: 'Confirmação de senha é obrigatória',
      );
    }

    if (password != confirmPassword) {
      return PasswordValidationResult(
        isValid: false,
        message: 'As senhas não coincidem',
      );
    }

    return PasswordValidationResult(
      isValid: true,
      message: 'Senhas coincidem',
    );
  }

  /// Valida senha completa (força + confirmação)
  static PasswordValidationResult validateCompletePassword(
    String password,
    String confirmPassword,
  ) {
    // Primeiro valida a força da senha
    final strengthResult = validatePassword(password);
    if (!strengthResult.isValid) {
      return strengthResult;
    }

    // Depois valida a confirmação
    return validatePasswordConfirmation(password, confirmPassword);
  }
}

class PasswordValidationResult {
  final bool isValid;
  final String message;

  const PasswordValidationResult({
    required this.isValid,
    required this.message,
  });
}
