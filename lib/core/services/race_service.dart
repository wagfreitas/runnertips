import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/race_model.dart';

class RaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _racesCollection = 'races';
<<<<<<< HEAD
  static const String _n8nWebhookUrl = 'https://n8n.wamconsultoria.com.br/webhook/89604726-f69e-4dec-b270-4c50e84d5e6e';
=======
  static const String _n8nWebhookUrl = 'https://n8n.wamconsultoria.com.br/webhook/corridas';
>>>>>>> 210d463 (feat: login, pesquisa prontos)

  /// Busca todas as corridas
  Future<List<RaceModel>> getAllRaces() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_racesCollection)
          .orderBy('eventDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => RaceModel.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Erro ao buscar corridas: $e');
      return [];
    }
  }

  /// Busca corridas por similaridade no nome
  Future<List<RaceModel>> searchRacesByName(String query) async {
    if (query.trim().isEmpty) {
      return getAllRaces();
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_racesCollection)
          .get();

      final List<RaceModel> allRaces = snapshot.docs
          .map((doc) => RaceModel.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();

      // Filtra por similaridade
      return _filterBySimilarity(allRaces, query.trim());
    } catch (e) {
      print('Erro ao buscar corridas: $e');
      return [];
    }
  }

  /// Filtra corridas por similaridade usando algoritmo de distância de Levenshtein
<<<<<<< HEAD
  List<RaceModel> _filterBySimilarity(List<RaceModel> races, String query) {
    final String normalizedQuery = _normalizeText(query);
    final List<RaceModel> filteredRaces = [];
=======
  /// Retorna apenas resultados com alta relevância (similaridade > 0.8 ou contém a query)
  List<RaceModel> _filterBySimilarity(List<RaceModel> races, String query) {
    final String normalizedQuery = _normalizeText(query);
    final List<RaceModel> filteredRaces = [];
    
    // Separa as palavras da query para busca mais precisa (ignora palavras muito curtas)
    final queryWords = normalizedQuery.split(' ').where((w) => w.length > 2).toList();
    
    print('🔍 Busca local - Query: "$normalizedQuery", Palavras: $queryWords');
>>>>>>> 210d463 (feat: login, pesquisa prontos)

    for (final race in races) {
      final String normalizedName = _normalizeText(race.name);
      final String normalizedLocation = _normalizeText(race.location);
<<<<<<< HEAD
      
      // Verifica se o query está contido no nome ou localização
      if (normalizedName.contains(normalizedQuery) || 
          normalizedLocation.contains(normalizedQuery)) {
        filteredRaces.add(race);
        continue;
      }

      // Calcula similaridade usando algoritmo de Levenshtein
      final double nameSimilarity = _calculateSimilarity(normalizedName, normalizedQuery);
      final double locationSimilarity = _calculateSimilarity(normalizedLocation, normalizedQuery);
      
      // Se a similaridade for maior que 0.6 (60%), inclui na lista
      if (nameSimilarity > 0.6 || locationSimilarity > 0.6) {
=======
      final String combinedText = '$normalizedName $normalizedLocation';
      
      // Verifica se a query está contida no nome ou localização (busca mais flexível)
      bool exactMatch = normalizedName.contains(normalizedQuery) || 
                       normalizedLocation.contains(normalizedQuery) ||
                       combinedText.contains(normalizedQuery);
      
      if (exactMatch) {
        print('✅ Match exato encontrado: ${race.name}');
        filteredRaces.add(race);
        continue;
      }
      
      // Se tem múltiplas palavras, verifica se a maioria está presente (pelo menos 60%)
      bool wordsMatch = false;
      if (queryWords.length > 1) {
        final matchesCount = queryWords.where((word) => 
          normalizedName.contains(word) || normalizedLocation.contains(word)
        ).length;
        
        // Aceita se pelo menos 60% das palavras estiverem presentes
        final matchRatio = matchesCount / queryWords.length;
        wordsMatch = matchRatio >= 0.6;
        
        if (wordsMatch) {
          print('✅ Match por palavras (${(matchRatio * 100).toInt()}% das palavras): ${race.name}');
          filteredRaces.add(race);
          continue;
        }
      } else if (queryWords.isNotEmpty) {
        // Para uma única palavra, verifica se está contida
        wordsMatch = normalizedName.contains(queryWords[0]) || 
                     normalizedLocation.contains(queryWords[0]);
        
        if (wordsMatch) {
          print('✅ Match por palavra única: ${race.name}');
          filteredRaces.add(race);
          continue;
        }
      }

      // Fallback: Calcula similaridade usando algoritmo de Levenshtein
      // Usa sempre, não apenas para queries curtas
      final double nameSimilarity = _calculateSimilarity(normalizedName, normalizedQuery);
      final double locationSimilarity = _calculateSimilarity(normalizedLocation, normalizedQuery);
      final double maxSimilarity = nameSimilarity > locationSimilarity ? nameSimilarity : locationSimilarity;
      
      // Threshold de 0.7 (70%) para ser menos restritivo e encontrar mais resultados
      if (maxSimilarity > 0.7) {
        print('✅ Match por similaridade (${(maxSimilarity * 100).toInt()}%): ${race.name}');
>>>>>>> 210d463 (feat: login, pesquisa prontos)
        filteredRaces.add(race);
      }
    }

<<<<<<< HEAD
=======
    print('📊 Resultados encontrados localmente: ${filteredRaces.length}');
    
>>>>>>> 210d463 (feat: login, pesquisa prontos)
    // Ordena por relevância (similaridade)
    filteredRaces.sort((a, b) {
      final double similarityA = _calculateSimilarity(_normalizeText(a.name), normalizedQuery);
      final double similarityB = _calculateSimilarity(_normalizeText(b.name), normalizedQuery);
      return similarityB.compareTo(similarityA);
    });

    return filteredRaces;
  }

  /// Normaliza texto para comparação (remove acentos, converte para minúsculas)
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
<<<<<<< HEAD
=======
        // Normaliza variações de "tóquio/tokyo"
        .replaceAll('óquio', 'oquio')
        .replaceAll('tokyo', 'toquio')
        // Normaliza variações de "maratón/maratona"
        .replaceAll('maraton', 'maratona')
>>>>>>> 210d463 (feat: login, pesquisa prontos)
        .trim();
  }

  /// Calcula similaridade entre duas strings usando algoritmo de Levenshtein
  double _calculateSimilarity(String s1, String s2) {
    final int distance = _levenshteinDistance(s1, s2);
    final int maxLength = [s1.length, s2.length].reduce((a, b) => a > b ? a : b);
    
    if (maxLength == 0) return 1.0;
    
    return 1.0 - (distance / maxLength);
  }

  /// Calcula a distância de Levenshtein entre duas strings
  int _levenshteinDistance(String s1, String s2) {
    final List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Busca corridas usando agente externo (n8n) quando não encontra resultados locais
  Future<List<RaceSuggestion>> searchExternalRaces(String query) async {
    try {
<<<<<<< HEAD
=======
      print('🌐 Chamando n8n webhook: $_n8nWebhookUrl');
      print('📤 Enviando query: $query');
      
      // Usa o formato 'text' conforme esperado pelo webhook do n8n
      final payload = jsonEncode({
        'text': query,
      });
      
>>>>>>> 210d463 (feat: login, pesquisa prontos)
      final response = await http.post(
        Uri.parse(_n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
<<<<<<< HEAD
        body: jsonEncode({
          'raceName': query,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Verifica se tem o formato de sugestões esperado
        if (data.containsKey('suggestions')) {
          final List<dynamic> suggestions = data['suggestions'] ?? [];
=======
        body: payload,
      );

      print('📥 Resposta recebida - Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      // Verifica se há erro no workflow do n8n
      if (response.statusCode == 500) {
        final errorData = jsonDecode(response.body);
        print('❌ Erro no workflow n8n: ${errorData['message']}');
        print('💡 Verifique se o workflow está ativo no n8n');
        return [];
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('📦 Dados recebidos: ${data.keys.toList()}');
        
        // Verifica se há erro na resposta
        if (data.containsKey('error')) {
          print('❌ Erro na resposta do n8n: ${data['error']}');
          return [];
        }
        
        // Processa o novo formato do n8n com conclusion e results
        if (data.containsKey('conclusion')) {
          final conclusion = data['conclusion'] as Map<String, dynamic>;
          final results = data['results'] as List<dynamic>? ?? [];
          
          print('✅ Formato de conclusion encontrado');
          
          // Extrai informações da conclusion
          var what = conclusion['what']?.toString() ?? query;
          final where = conclusion['where']?.toString() ?? conclusion['location']?.toString() ?? data['location']?.toString() ?? 'Localização não especificada';
          final when = conclusion['when']?.toString() ?? 'Data não especificada';
          final distance = conclusion['distance']?.toString() ?? 'Distância não especificada';
          final registration = conclusion['registration']?.toString() ?? '';
          
          // Extrai URL da imagem (prioriza conclusion, depois busca nos results)
          String? imageUrl = conclusion['image_url']?.toString() ?? 
                            conclusion['imageUrl']?.toString() ??
                            conclusion['image']?.toString();
          
          // Limita o nome da corrida (remove descrições longas)
          // Se o "what" for muito longo, tenta extrair apenas o nome
          if (what.length > 60) {
            // Tenta pegar a primeira frase ou até o primeiro ponto
            final firstSentence = what.split('.')[0];
            if (firstSentence.length <= 60 && firstSentence.length > 10) {
              what = firstSentence;
            } else {
              // Se ainda for longo, pega apenas as primeiras palavras
              final words = what.split(' ');
              if (words.length > 8) {
                what = words.take(8).join(' ');
              }
            }
          }
          
          // Prioriza site oficial da conclusion, depois busca nos results
          String? websiteUrl = conclusion['website']?.toString();
          
          // Se não tem website na conclusion, busca nos results (priorizando oficiais)
          if (websiteUrl == null || websiteUrl.isEmpty) {
            // Primeiro tenta encontrar site oficial nos results
            for (final result in results) {
              final resultMap = result as Map<String, dynamic>?;
              if (resultMap?['is_official'] == true) {
                websiteUrl = resultMap?['url']?.toString();
                break;
              }
            }
            
            // Se não encontrou oficial, pega o primeiro resultado
            if (websiteUrl == null || websiteUrl.isEmpty) {
              if (results.isNotEmpty) {
                final firstResult = results[0] as Map<String, dynamic>?;
                websiteUrl = firstResult?['url']?.toString();
              }
            }
          }
          
          // Extrai organizador
          final organizer = conclusion['organizer']?.toString() ?? 'N8N Agent';
          
          // Identifica se encontrou site oficial
          final officialSite = results.any((r) => 
            (r as Map<String, dynamic>?)?['is_official'] == true
          ) || (websiteUrl != null && websiteUrl.isNotEmpty);
          
          // Extrai mês e ano da data quando disponível
          String month = 'Verificar detalhes';
          String year = DateTime.now().year.toString();
          
          // Tenta extrair mês e ano da string de data
          // Formato: "30 de Agosto, 2026" ou "30/08/2026"
          final dateMatch = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})').firstMatch(when);
          if (dateMatch != null) {
            final monthNum = int.tryParse(dateMatch.group(2) ?? '');
            if (monthNum != null && monthNum >= 1 && monthNum <= 12) {
              final months = ['January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'];
              month = months[monthNum - 1];
            }
            year = dateMatch.group(3) ?? year;
          } else {
            // Tenta extrair mês por nome (ex: "30 de Agosto, 2026")
            final monthNames = {
              'janeiro': 'January', 'fevereiro': 'February', 'março': 'March',
              'abril': 'April', 'maio': 'May', 'junho': 'June',
              'julho': 'July', 'agosto': 'August', 'setembro': 'September',
              'outubro': 'October', 'novembro': 'November', 'dezembro': 'December'
            };
            final whenLower = when.toLowerCase();
            for (final entry in monthNames.entries) {
              if (whenLower.contains(entry.key)) {
                month = entry.value;
                break;
              }
            }
            // Tenta extrair ano
            final yearMatch = RegExp(r'(\d{4})').firstMatch(when);
            if (yearMatch != null) {
              year = yearMatch.group(1) ?? year;
            }
          }
          
          // Cria descrição combinando informações
          final description = '''${officialSite ? '✅ Site oficial encontrado\n\n' : ''}$what
          
Localização: $where
Data: $when
Distância: $distance
${registration.isNotEmpty ? 'Inscrição: $registration' : ''}
${websiteUrl != null && websiteUrl.isNotEmpty ? 'Site: $websiteUrl' : ''}
${results.isNotEmpty ? '\nFontes consultadas: ${results.length} fonte(s)' : ''}''';
          
          // Se não encontrou imagem na conclusion, tenta extrair dos results
          if (imageUrl == null || imageUrl.isEmpty) {
            // Busca imagens nos resultados (se o SearchAPI retornar)
            for (final result in results) {
              final resultMap = result as Map<String, dynamic>?;
              if (resultMap?['image'] != null) {
                imageUrl = resultMap?['image']?.toString();
                break;
              }
            }
          }
          
          return [
            RaceSuggestion(
              name: what,
              location: where,
              distance: distance,
              month: month,
              year: year,
              imageUrl: imageUrl ?? '', // Usa URL da imagem ou placeholder local
              description: description,
              website: websiteUrl,
              organizer: organizer,
              confidence: officialSite ? 0.9 : 0.8, // Maior confiança se for site oficial
            ),
          ];
        }
        
        // Fallback: formato antigo de sugestões (se ainda existir)
        if (data.containsKey('suggestions')) {
          final List<dynamic> suggestions = data['suggestions'] ?? [];
          print('✅ Formato de sugestões encontrado: ${suggestions.length} sugestões');
>>>>>>> 210d463 (feat: login, pesquisa prontos)
          return suggestions
              .map((suggestion) => RaceSuggestion.fromMap(suggestion))
              .toList();
        }
        
<<<<<<< HEAD
        // Se não tem sugestões, mas tem output (formato atual do N8N)
        if (data.containsKey('output')) {
          final String output = data['output'];
          // Cria uma sugestão baseada no output do N8N
          return [
            RaceSuggestion(
              name: query, // Usa a query original como nome
              location: 'Informação disponível no N8N',
              distance: 'Verificar detalhes',
              month: 'Verificar detalhes',
              year: '2024',
              imageUrl: 'https://via.placeholder.com/300x200?text=Race+Info',
=======
        // Fallback: formato de output simples
        if (data.containsKey('output')) {
          final String output = data['output'];
          print('✅ Formato de output encontrado, criando sugestão');
          return [
            RaceSuggestion(
              name: query,
              location: data['location']?.toString() ?? 'Informação disponível no N8N',
              distance: 'Verificar detalhes',
              month: 'Verificar detalhes',
              year: DateTime.now().year.toString(),
              imageUrl: '', // Usa placeholder local
>>>>>>> 210d463 (feat: login, pesquisa prontos)
              description: output,
              website: '',
              organizer: 'N8N Agent',
              confidence: 0.8,
            ),
          ];
        }
        
<<<<<<< HEAD
        return [];
      } else {
        print('Erro na busca externa: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar corridas externas: $e');
=======
        print('⚠️ Formato desconhecido na resposta: ${data.keys.toList()}');
        return [];
      } else {
        print('❌ Erro na busca externa: Status ${response.statusCode}');
        print('❌ Body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao buscar corridas externas: $e');
      print('❌ Stack trace: $stackTrace');
>>>>>>> 210d463 (feat: login, pesquisa prontos)
      return [];
    }
  }

  /// Adiciona uma nova corrida ao banco de dados
  Future<String?> addRace(RaceModel race) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection(_racesCollection)
          .add(race.toMap());

      return docRef.id;
    } catch (e) {
      print('Erro ao adicionar corrida: $e');
      return null;
    }
  }

  /// Adiciona uma corrida sugerida (convertida de RaceSuggestion)
  Future<String?> addSuggestedRace(RaceSuggestion suggestion) async {
    try {
      final race = RaceModel(
        id: '', // Será gerado pelo Firestore
        name: suggestion.name,
        location: suggestion.location,
        distance: suggestion.distance,
        month: suggestion.month,
        year: suggestion.year,
        imageUrl: suggestion.imageUrl,
        description: suggestion.description,
        status: 'Open',
        eventDate: DateTime.now().add(const Duration(days: 30)), // Data padrão
        registrationDeadline: DateTime.now().add(const Duration(days: 25)),
        website: suggestion.website,
        organizer: suggestion.organizer,
        categories: _extractCategoriesFromDistance(suggestion.distance),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isExternal: true,
      );

      return await addRace(race);
    } catch (e) {
      print('Erro ao adicionar corrida sugerida: $e');
      return null;
    }
  }

  /// Extrai categorias baseadas na distância
  List<String> _extractCategoriesFromDistance(String distance) {
    final String normalizedDistance = distance.toLowerCase();
    
    if (normalizedDistance.contains('marathon') || normalizedDistance.contains('42')) {
      return ['Marathon'];
    } else if (normalizedDistance.contains('half') || normalizedDistance.contains('21')) {
      return ['Half Marathon'];
    } else if (normalizedDistance.contains('10k') || normalizedDistance.contains('10')) {
      return ['10K'];
    } else if (normalizedDistance.contains('5k') || normalizedDistance.contains('5')) {
      return ['5K'];
    } else {
      return ['Running'];
    }
  }

  /// Busca uma corrida por ID
  Future<RaceModel?> getRaceById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_racesCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return RaceModel.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      print('Erro ao buscar corrida por ID: $e');
      return null;
    }
  }

  /// Atualiza uma corrida existente
  Future<bool> updateRace(RaceModel race) async {
    try {
      await _firestore
          .collection(_racesCollection)
          .doc(race.id)
          .update(race.copyWith(updatedAt: DateTime.now()).toMap());
      
      return true;
    } catch (e) {
      print('Erro ao atualizar corrida: $e');
      return false;
    }
  }

  /// Remove uma corrida
  Future<bool> deleteRace(String id) async {
    try {
      await _firestore
          .collection(_racesCollection)
          .doc(id)
          .delete();
      
      return true;
    } catch (e) {
      print('Erro ao remover corrida: $e');
      return false;
    }
  }
}
