import '../models/tip_model.dart';

class ContentValidator {
  static final List<String> sportKeywords = [
    // Corridas
    'maratona',
    'marathon',
    'corrida',
    'race',
    'run',
    'running',
    'meia maratona',
    'half marathon',
    '21k',
    '42k',
    'ultramaratona',
    'ultra marathon',
    'ultra',
    'trail',
    'trail running',
    'mountain running',
    
    // Triatlos
    'triatlo',
    'triathlon',
    'ironman',
    'iron man',
    'duatlo',
    'duathlon',
    
    // Caminhadas
    'caminhada',
    'walk',
    'walking',
    'hiking',
    
    // Eventos
    'evento',
    'event',
    'prova',
    'competition',
    'largada',
    'start',
    'chegada',
    'finish',
    
    // Atletas
    'corredor',
    'runner',
    'atleta',
    'athlete',
    'participante',
    'participant',
    
    // Distâncias
    '5k',
    '10k',
    '15k',
    '21k',
    '42k',
    'meia maratona',
    'half',
    'maratona completa',
    'full',
  ];

  /// Verifica se o conteúdo está relacionado a eventos esportivos
  static bool isSportsRelated(String content) {
    if (content.isEmpty) return false;
    
    final lowerContent = content.toLowerCase();
    return sportKeywords.any((keyword) => lowerContent.contains(keyword));
  }

  /// Valida uma dica completa
  static ValidationResult validateTip(TipModel tip) {
    // Validar título
    if (tip.title.isEmpty) {
      return ValidationResult(
        valid: false,
        reason: 'O título não pode estar vazio',
      );
    }

    if (tip.title.length < 5) {
      return ValidationResult(
        valid: false,
        reason: 'O título deve ter pelo menos 5 caracteres',
      );
    }

    if (!isSportsRelated(tip.title)) {
      return ValidationResult(
        valid: false,
        reason: 'O título deve estar relacionado a eventos esportivos',
      );
    }

    // Validar conteúdo
    if (tip.content.isEmpty) {
      return ValidationResult(
        valid: false,
        reason: 'O conteúdo não pode estar vazio',
      );
    }

    if (tip.content.length < 20) {
      return ValidationResult(
        valid: false,
        reason: 'O conteúdo deve ter pelo menos 20 caracteres',
      );
    }

    if (!isSportsRelated(tip.content)) {
      return ValidationResult(
        valid: false,
        reason: 'O conteúdo deve estar relacionado a eventos esportivos',
      );
    }

    // Validar se está vinculado a uma corrida ou cidade
    if (tip.raceId == null && tip.cityId == null) {
      return ValidationResult(
        valid: false,
        reason: 'A dica deve estar vinculada a uma corrida ou cidade',
      );
    }

    return ValidationResult(valid: true);
  }

  /// Valida um texto genérico
  static ValidationResult validateText(String text, {int minLength = 10}) {
    if (text.isEmpty) {
      return ValidationResult(
        valid: false,
        reason: 'O texto não pode estar vazio',
      );
    }

    if (text.length < minLength) {
      return ValidationResult(
        valid: false,
        reason: 'O texto deve ter pelo menos $minLength caracteres',
      );
    }

    if (!isSportsRelated(text)) {
      return ValidationResult(
        valid: false,
        reason: 'O texto deve estar relacionado a eventos esportivos',
      );
    }

    return ValidationResult(valid: true);
  }

  /// Extrai palavras-chave relacionadas a esportes do texto
  static List<String> extractSportKeywords(String text) {
    final lowerText = text.toLowerCase();
    return sportKeywords
        .where((keyword) => lowerText.contains(keyword))
        .toList();
  }
}

class ValidationResult {
  final bool valid;
  final String? reason;

  ValidationResult({required this.valid, this.reason});

  @override
  String toString() {
    return valid ? 'Válido' : 'Inválido: $reason';
  }
}

