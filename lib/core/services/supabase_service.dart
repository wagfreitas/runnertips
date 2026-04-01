import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';
import '../models/knowledge_chunk.dart';
import '../models/race_route.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    _client = Supabase.instance.client;
  }

  // ─── Knowledge Chunks ───────────────────────────────────────

  Future<List<KnowledgeChunk>> searchKnowledge({
    required List<double> queryEmbedding,
    String? queryText,
    String? raceId,
    String? category,
    String language = 'pt',
    int matchCount = 10,
  }) async {
    final response = await _client.rpc(
      SupabaseConfig.searchKnowledgeRpc,
      params: {
        'query_embedding': queryEmbedding.toString(),
        'query_text': queryText ?? '',
        'filter_race_id': raceId,
        'filter_category': category,
        'filter_language': language,
        'match_count': matchCount,
      },
    );

    final data = response as List;
    return data
        .map((item) => KnowledgeChunk.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<KnowledgeChunk>> getChunksByRace(String raceId) async {
    final response = await _client
        .from(SupabaseConfig.knowledgeChunksTable)
        .select()
        .eq('race_id', raceId)
        .eq('is_verified', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => KnowledgeChunk.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<KnowledgeChunk>> getChunksByCategory(
    KnowledgeCategory category, {
    String? raceId,
    int limit = 20,
  }) async {
    var query = _client
        .from(SupabaseConfig.knowledgeChunksTable)
        .select()
        .eq('category', category.dbValue)
        .eq('is_verified', true);

    if (raceId != null) {
      query = query.eq('race_id', raceId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((item) => KnowledgeChunk.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<KnowledgeChunk> insertChunk(KnowledgeChunk chunk) async {
    final response = await _client
        .from(SupabaseConfig.knowledgeChunksTable)
        .insert(chunk.toMap())
        .select()
        .single();

    return KnowledgeChunk.fromMap(response);
  }

  Future<void> updateChunkVerification(String chunkId, bool isVerified) async {
    await _client
        .from(SupabaseConfig.knowledgeChunksTable)
        .update({'is_verified': isVerified})
        .eq('id', chunkId);
  }

  // ─── Race Routes ────────────────────────────────────────────

  Future<RaceRoute?> getRouteByRaceId(String raceId) async {
    final response = await _client
        .from(SupabaseConfig.raceRoutesTable)
        .select()
        .eq('race_id', raceId)
        .maybeSingle();

    if (response == null) return null;
    return RaceRoute.fromMap(response);
  }

  Future<RaceRoute> insertRoute(RaceRoute route) async {
    final response = await _client
        .from(SupabaseConfig.raceRoutesTable)
        .insert(route.toMap())
        .select()
        .single();

    return RaceRoute.fromMap(response);
  }

  Future<RaceRoute> upsertRoute(RaceRoute route) async {
    final response = await _client
        .from(SupabaseConfig.raceRoutesTable)
        .upsert(route.toMap(), onConflict: 'race_id')
        .select()
        .single();

    return RaceRoute.fromMap(response);
  }

  // ─── Stats ──────────────────────────────────────────────────

  Future<int> getChunkCountByRace(String raceId) async {
    final response = await _client
        .from(SupabaseConfig.knowledgeChunksTable)
        .select()
        .eq('race_id', raceId)
        .eq('is_verified', true)
        .count(CountOption.exact);

    return response.count;
  }

  Future<Map<String, int>> getCategoryCountsByRace(String raceId) async {
    final response = await _client
        .from(SupabaseConfig.knowledgeChunksTable)
        .select('category')
        .eq('race_id', raceId)
        .eq('is_verified', true);

    final data = response as List;
    final counts = <String, int>{};
    for (final item in data) {
      final cat = item['category'] as String;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }
}
