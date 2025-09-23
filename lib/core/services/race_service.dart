import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/race_model.dart';

class RaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _racesCollection = 'races';
  static const String _n8nWebhookUrl = 'https://n8n.wamconsultoria.com.br/webhook/89604726-f69e-4dec-b270-4c50e84d5e6e';

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
  List<RaceModel> _filterBySimilarity(List<RaceModel> races, String query) {
    final String normalizedQuery = _normalizeText(query);
    final List<RaceModel> filteredRaces = [];

    for (final race in races) {
      final String normalizedName = _normalizeText(race.name);
      final String normalizedLocation = _normalizeText(race.location);
      
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
        filteredRaces.add(race);
      }
    }

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
      final response = await http.post(
        Uri.parse(_n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'raceName': query,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Verifica se tem o formato de sugestões esperado
        if (data.containsKey('suggestions')) {
          final List<dynamic> suggestions = data['suggestions'] ?? [];
          return suggestions
              .map((suggestion) => RaceSuggestion.fromMap(suggestion))
              .toList();
        }
        
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
              description: output,
              website: '',
              organizer: 'N8N Agent',
              confidence: 0.8,
            ),
          ];
        }
        
        return [];
      } else {
        print('Erro na busca externa: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar corridas externas: $e');
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
