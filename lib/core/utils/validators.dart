class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }
  
  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    
    if (value != password) {
      return 'Senhas não coincidem';
    }
    
    return null;
  }
  
  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    if (value.length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }
    
    return null;
  }
  
  // Bio validation
  static String? bio(String? value) {
    if (value != null && value.length > 500) {
      return 'Bio deve ter no máximo 500 caracteres';
    }
    
    return null;
  }
  
  // Tip title validation
  static String? tipTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Título é obrigatório';
    }
    
    if (value.length < 5) {
      return 'Título deve ter pelo menos 5 caracteres';
    }
    
    if (value.length > 255) {
      return 'Título deve ter no máximo 255 caracteres';
    }
    
    return null;
  }
  
  // Tip content validation
  static String? tipContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Conteúdo é obrigatório';
    }
    
    if (value.length < 20) {
      return 'Conteúdo deve ter pelo menos 20 caracteres';
    }
    
    if (value.length > 2000) {
      return 'Conteúdo deve ter no máximo 2000 caracteres';
    }
    
    return null;
  }
  
  // Comment validation
  static String? comment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Comentário é obrigatório';
    }
    
    if (value.length < 3) {
      return 'Comentário deve ter pelo menos 3 caracteres';
    }
    
    if (value.length > 500) {
      return 'Comentário deve ter no máximo 500 caracteres';
    }
    
    return null;
  }
  
  // Search query validation
  static String? searchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Termo de busca é obrigatório';
    }
    
    if (value.length < 2) {
      return 'Termo de busca deve ter pelo menos 2 caracteres';
    }
    
    return null;
  }
  
  // Phone validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Telefone inválido';
    }
    
    return null;
  }
  
  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'URL inválida';
    }
    
    return null;
  }
  
  // Required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    
    return null;
  }
  
  // Min length validation
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value != null && value.length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }
    
    return null;
  }
  
  // Max length validation
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName deve ter no máximo $maxLength caracteres';
    }
    
    return null;
  }
  
  // Numeric validation
  static String? numeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for optional fields
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName deve ser um número válido';
    }
    
    return null;
  }
  
  // Positive number validation
  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Allow empty for optional fields
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName deve ser um número válido';
    }
    
    if (number <= 0) {
      return '$fieldName deve ser maior que zero';
    }
    
    return null;
  }
}
