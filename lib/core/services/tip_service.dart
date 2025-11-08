import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tip_model.dart';
import '../utils/content_validator.dart';

enum TipSortOption {
  recent,
  mostHelpful,
  mostViewed,
  mostLiked,
}

class TipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tips';

  /// Cria uma nova dica
  Future<String?> createTip(TipModel tip) async {
    try {
      // Validar conteúdo
      final validation = ContentValidator.validateTip(tip);
      if (!validation.valid) {
        throw Exception(validation.reason ?? 'Validação falhou');
      }

      // Preparar dados para salvar
      final tipData = tip.toMap();
      tipData['createdAt'] = FieldValue.serverTimestamp();
      tipData['updatedAt'] = FieldValue.serverTimestamp();
      tipData.remove('id'); // Remove ID para o Firestore gerar

      // Salvar no Firestore
      final docRef = await _firestore.collection(_collection).add(tipData);
      
      print('✅ Dica criada com sucesso: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Erro ao criar dica: $e');
      return null;
    }
  }

  /// Busca dicas com filtros, ordenação e busca textual
  Future<List<TipModel>> getTips({
    String? raceId,
    String? cityId,
    TipType? type,
    TipCategory? category,
    TipSortOption sortOption = TipSortOption.recent,
    String? searchTerm,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Aplicar filtros
      if (raceId != null) {
        query = query.where('raceId', isEqualTo: raceId);
      }
      if (cityId != null) {
        query = query.where('cityId', isEqualTo: cityId);
      }
      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      // Sempre filtrar apenas ativos
      query = query.where('isActive', isEqualTo: true);

      // NÃO usar orderBy na query para evitar necessidade de índice composto
      // A ordenação será feita localmente após buscar os dados
      // Limitar resultados para não sobrecarregar (buscar mais para compensar ordenação local)
      if (limit != null) {
        // Buscar 3x mais para ter margem após filtros e ordenação local
        query = query.limit(limit * 3);
      } else {
        // Limitar a 100 resultados se não especificado, para não sobrecarregar
        query = query.limit(100);
      }

      final snapshot = await query.get();
      
      List<TipModel> tips = snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TipModel.fromMap({
              'id': doc.id,
              ...data,
            });
          })
          .toList();
      
      // Sempre ordenar localmente por data de criação (evita necessidade de índice)
      tips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Aplicar limite após ordenação
      if (limit != null && tips.length > limit) {
        tips = tips.take(limit).toList();
      }

      // Aplicar busca textual (título, conteúdo, tags)
      List<TipModel> filteredTips = tips;
      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        final normalizedSearch = searchTerm.toLowerCase().trim();
        filteredTips = tips.where((tip) {
          final titleMatch = tip.title.toLowerCase().contains(normalizedSearch);
          final contentMatch = tip.content.toLowerCase().contains(normalizedSearch);
          final tagMatch = tip.tags.any(
            (tag) => tag.toLowerCase().contains(normalizedSearch),
          );
          return titleMatch || contentMatch || tagMatch;
        }).toList();
      }

      // Aplicar ordenação específica
      switch (sortOption) {
        case TipSortOption.mostHelpful:
          filteredTips.sort(
            (a, b) => b.stats.helpfulness.compareTo(a.stats.helpfulness),
          );
          break;
        case TipSortOption.mostViewed:
          filteredTips.sort(
            (a, b) => b.stats.views.compareTo(a.stats.views),
          );
          break;
        case TipSortOption.mostLiked:
          filteredTips.sort(
            (a, b) => b.stats.likes.compareTo(a.stats.likes),
          );
          break;
        case TipSortOption.recent:
          filteredTips.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          break;
      }

      print('✅ ${filteredTips.length} dicas encontradas');
      return filteredTips;
    } catch (e) {
      print('❌ Erro ao buscar dicas: $e');
      return [];
    }
  }

  /// Busca uma dica por ID
  Future<TipModel?> getTipById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['isActive'] = data['isActive'] ?? true;
        
        if (data['isActive'] == false) {
          return null; // Não retornar dicas inativas
        }

        return TipModel.fromMap({
          'id': doc.id,
          ...data,
        });
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar dica: $e');
      return null;
    }
  }

  /// Atualiza uma dica existente
  Future<bool> updateTip(TipModel tip) async {
    try {
      // Validar conteúdo
      final validation = ContentValidator.validateTip(tip);
      if (!validation.valid) {
        throw Exception(validation.reason ?? 'Validação falhou');
      }

      // Preparar dados para atualizar
      final tipData = tip.toMap();
      tipData['updatedAt'] = FieldValue.serverTimestamp();
      tipData.remove('id'); // Remove ID (não atualiza)
      tipData.remove('createdAt'); // Não atualiza data de criação

      await _firestore.collection(_collection).doc(tip.id).update(tipData);
      
      print('✅ Dica atualizada com sucesso: ${tip.id}');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar dica: $e');
      return false;
    }
  }

  /// Conta dicas por tipo/categoria para uma corrida ou cidade
  Future<Map<TipType, int>> getTipsCountByType({
    String? raceId,
    String? cityId,
  }) async {
    try {
      Query query = _firestore.collection(_collection);
      
      if (raceId != null) {
        query = query.where('raceId', isEqualTo: raceId);
      }
      if (cityId != null) {
        query = query.where('cityId', isEqualTo: cityId);
      }
      
      query = query.where('isActive', isEqualTo: true);
      
      final snapshot = await query.get();
      
      final Map<TipType, int> counts = {};
      for (final type in TipType.values) {
        counts[type] = 0;
      }
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data != null) {
          final dataMap = data as Map<String, dynamic>;
          if (dataMap['type'] != null) {
            try {
              final type = TipType.values.firstWhere(
                (e) => e.name == dataMap['type'],
                orElse: () => TipType.general,
              );
              counts[type] = (counts[type] ?? 0) + 1;
            } catch (e) {
              // Ignora erros de parsing
            }
          }
        }
      }
      
      return counts;
    } catch (e) {
      print('❌ Erro ao contar dicas por tipo: $e');
      return {};
    }
  }

  /// Deleta uma dica (soft delete - marca como inativa)
  Future<bool> deleteTip(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Dica deletada com sucesso: $id');
      return true;
    } catch (e) {
      print('❌ Erro ao deletar dica: $e');
      return false;
    }
  }

  /// Incrementa contador de views
  Future<void> incrementViews(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'stats.views': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao incrementar views: $e');
    }
  }

  /// Incrementa contador de likes
  Future<void> toggleLike(String id, bool isLiked) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'stats.likes': FieldValue.increment(isLiked ? 1 : -1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao atualizar like: $e');
    }
  }

  /// Busca dicas por texto (busca simples)
  Future<List<TipModel>> searchTips(String searchText) async {
    try {
      if (searchText.isEmpty) {
        return await getTips();
      }

      // Busca todas as dicas ativas
      final allTips = await getTips();

      // Filtra localmente (busca simples)
      final lowerSearch = searchText.toLowerCase();
      return allTips.where((tip) {
        return tip.title.toLowerCase().contains(lowerSearch) ||
            tip.content.toLowerCase().contains(lowerSearch) ||
            tip.tags.any((tag) => tag.toLowerCase().contains(lowerSearch));
      }).toList();
    } catch (e) {
      print('❌ Erro ao buscar dicas: $e');
      return [];
    }
  }
}

