import 'package:flutter/material.dart';
import '../../../../core/services/race_service.dart';
import '../../../../core/models/race_model.dart';

class RaceProvider extends ChangeNotifier {
  final RaceService _raceService = RaceService();
  
  List<RaceModel> _races = [];
  List<RaceSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  String? _errorMessage;
<<<<<<< HEAD
=======
  String? _successMessage;
>>>>>>> 210d463 (feat: login, pesquisa prontos)
  String _searchQuery = '';

  // Getters
  List<RaceModel> get races => _races;
  List<RaceSuggestion> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get showSuggestions => _showSuggestions;
  String? get errorMessage => _errorMessage;
<<<<<<< HEAD
=======
  String? get successMessage => _successMessage;
>>>>>>> 210d463 (feat: login, pesquisa prontos)
  String get searchQuery => _searchQuery;

  /// Carrega todas as corridas
  Future<void> loadRaces() async {
    _setLoading(true);
    _clearError();

    try {
      _races = await _raceService.getAllRaces();
      _setLoading(false);
    } catch (e) {
      _setError('Erro ao carregar corridas: ${e.toString()}');
      _setLoading(false);
    }
  }

<<<<<<< HEAD
  /// Busca corridas por nome
  Future<void> searchRaces(String query) async {
=======
  /// Busca corridas por nome (apenas busca local)
  Future<void> searchRaces(String query) async {
    print('🔍 Iniciando busca por: "$query"');
>>>>>>> 210d463 (feat: login, pesquisa prontos)
    _searchQuery = query;
    _isSearching = true;
    _showSuggestions = false;
    _clearError();
    notifyListeners();

    try {
      if (query.trim().isEmpty) {
<<<<<<< HEAD
        await loadRaces();
      } else {
        _races = await _raceService.searchRacesByName(query);
        
        // Se não encontrou resultados, busca externamente
        if (_races.isEmpty) {
          await _searchExternalRaces(query);
        }
      }
    } catch (e) {
=======
        print('📋 Busca vazia, carregando todas as corridas');
        await loadRaces();
      } else {
        print('🔎 Buscando localmente por: "$query"');
        _races = await _raceService.searchRacesByName(query);
        print('📊 Resultados locais: ${_races.length} corridas encontradas');
        
        // Não busca externamente automaticamente - aguarda o usuário clicar no botão
        if (_races.isEmpty) {
          print('⚠️ Nenhum resultado local encontrado - aguardando ação do usuário');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Erro na busca: $e');
      print('Stack trace: $stackTrace');
>>>>>>> 210d463 (feat: login, pesquisa prontos)
      _setError('Erro ao buscar corridas: ${e.toString()}');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

<<<<<<< HEAD
  /// Busca corridas externamente quando não encontra resultados locais
  Future<void> _searchExternalRaces(String query) async {
    try {
      _suggestions = await _raceService.searchExternalRaces(query);
      
      if (_suggestions.isNotEmpty) {
        _showSuggestions = true;
      } else {
        _setError('Nenhuma corrida encontrada. Tente buscar por termos diferentes.');
      }
    } catch (e) {
      _setError('Erro ao buscar corridas externas: ${e.toString()}');
=======
  /// Busca corridas externamente usando IA (n8n) - chamado manualmente pelo usuário
  Future<void> searchExternalRaces() async {
    if (_searchQuery.trim().isEmpty) {
      _setError('Digite algo para buscar');
      return;
    }
    
    await _searchExternalRaces(_searchQuery);
  }

  /// Busca corridas externamente usando IA (n8n)
  Future<void> _searchExternalRaces(String query) async {
    try {
      print('🔍 Buscando externamente por: $query');
      _setLoading(true);
      notifyListeners();
      
      // Busca sugestões do n8n
      _suggestions = await _raceService.searchExternalRaces(query);
      print('📦 Sugestões recebidas do n8n: ${_suggestions.length}');
      
      if (_suggestions.isNotEmpty) {
        // Adiciona automaticamente todas as sugestões ao banco de dados
        int addedCount = 0;
        for (final suggestion in _suggestions) {
          try {
            print('➕ Adicionando corrida: ${suggestion.name}');
            final raceId = await _raceService.addSuggestedRace(suggestion);
            if (raceId != null) {
              addedCount++;
              print('✅ Corrida adicionada com ID: $raceId');
            } else {
              print('❌ Falha ao adicionar corrida: ${suggestion.name}');
            }
          } catch (e) {
            print('❌ Erro ao adicionar sugestão ${suggestion.name}: $e');
          }
        }
        
        print('📊 Total de corridas adicionadas: $addedCount');
        
        // Faz uma nova busca local com a query para mostrar as corridas recém-adicionadas
        _races = await _raceService.searchRacesByName(query);
        print('🔍 Busca local após adicionar: ${_races.length} corridas encontradas');
        
        // Limpa as sugestões já que foram adicionadas
        _suggestions.clear();
        _showSuggestions = false;
        
        if (addedCount > 0) {
          // Mostra mensagem de sucesso
          _clearError();
          _setSuccessMessage('✅ $addedCount corrida(s) encontrada(s) e adicionada(s) automaticamente!');
          print('✅ $addedCount corrida(s) adicionada(s) automaticamente ao banco de dados');
        } else {
          _setError('Nenhuma corrida pôde ser adicionada ao banco de dados.');
        }
      } else {
        print('⚠️ Nenhuma sugestão recebida do n8n');
        _setError('Nenhuma corrida encontrada. Tente buscar por termos diferentes.');
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao buscar corridas externas: $e');
      print('Stack trace: $stackTrace');
      _setError('Erro ao buscar corridas externas: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
>>>>>>> 210d463 (feat: login, pesquisa prontos)
    }
  }

  /// Adiciona uma corrida sugerida ao banco de dados
  Future<bool> addSuggestedRace(RaceSuggestion suggestion) async {
    try {
      final raceId = await _raceService.addSuggestedRace(suggestion);
      
      if (raceId != null) {
        // Remove a sugestão da lista
        _suggestions.removeWhere((s) => s == suggestion);
        
        // Recarrega as corridas
        await loadRaces();
        
        // Se não há mais sugestões, esconde a lista
        if (_suggestions.isEmpty) {
          _showSuggestions = false;
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao adicionar corrida: ${e.toString()}');
      return false;
    }
  }

  /// Adiciona uma nova corrida
  Future<bool> addRace(RaceModel race) async {
    try {
      final raceId = await _raceService.addRace(race);
      
      if (raceId != null) {
        await loadRaces(); // Recarrega a lista
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erro ao adicionar corrida: ${e.toString()}');
      return false;
    }
  }

  /// Atualiza uma corrida existente
  Future<bool> updateRace(RaceModel race) async {
    try {
      final success = await _raceService.updateRace(race);
      
      if (success) {
        await loadRaces(); // Recarrega a lista
      }
      
      return success;
    } catch (e) {
      _setError('Erro ao atualizar corrida: ${e.toString()}');
      return false;
    }
  }

  /// Remove uma corrida
  Future<bool> deleteRace(String raceId) async {
    try {
      final success = await _raceService.deleteRace(raceId);
      
      if (success) {
        await loadRaces(); // Recarrega a lista
      }
      
      return success;
    } catch (e) {
      _setError('Erro ao remover corrida: ${e.toString()}');
      return false;
    }
  }

  /// Busca uma corrida por ID
  Future<RaceModel?> getRaceById(String id) async {
    try {
      return await _raceService.getRaceById(id);
    } catch (e) {
      _setError('Erro ao buscar corrida: ${e.toString()}');
      return null;
    }
  }

  /// Limpa a busca e volta para a lista completa
  void clearSearch() {
    _searchQuery = '';
    _showSuggestions = false;
    _suggestions.clear();
    loadRaces();
  }

  /// Filtra corridas por status
  List<RaceModel> getRacesByStatus(String status) {
    return _races.where((race) => race.status == status).toList();
  }

  /// Filtra corridas por localização
  List<RaceModel> getRacesByLocation(String location) {
    return _races.where((race) => 
      race.location.toLowerCase().contains(location.toLowerCase())
    ).toList();
  }

  /// Filtra corridas por distância
  List<RaceModel> getRacesByDistance(String distance) {
    return _races.where((race) => 
      race.distance.toLowerCase().contains(distance.toLowerCase())
    ).toList();
  }

  /// Filtra corridas por mês
  List<RaceModel> getRacesByMonth(String month) {
    return _races.where((race) => 
      race.month.toLowerCase().contains(month.toLowerCase())
    ).toList();
  }

  /// Obtém estatísticas das corridas
  Map<String, int> getRaceStats() {
    final Map<String, int> stats = {};
    
    for (final race in _races) {
      stats[race.status] = (stats[race.status] ?? 0) + 1;
    }
    
    return stats;
  }

  /// Limpa mensagens de erro
  void _clearError() {
    _errorMessage = null;
<<<<<<< HEAD
=======
    _successMessage = null;
>>>>>>> 210d463 (feat: login, pesquisa prontos)
    notifyListeners();
  }

  /// Define mensagem de erro
  void _setError(String message) {
    _errorMessage = message;
<<<<<<< HEAD
    notifyListeners();
  }

=======
    _successMessage = null; // Limpa mensagem de sucesso quando há erro
    notifyListeners();
  }

  /// Define mensagem de sucesso
  void _setSuccessMessage(String message) {
    _successMessage = message;
    _errorMessage = null; // Limpa erro quando há sucesso
    notifyListeners();
    
    // Remove a mensagem de sucesso após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (_successMessage == message) {
        _successMessage = null;
        notifyListeners();
      }
    });
  }

>>>>>>> 210d463 (feat: login, pesquisa prontos)
  /// Define estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Limpa todas as mensagens e estados
  void clearMessages() {
    _errorMessage = null;
<<<<<<< HEAD
=======
    _successMessage = null;
>>>>>>> 210d463 (feat: login, pesquisa prontos)
    notifyListeners();
  }
}
