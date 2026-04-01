import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/knowledge_chunk.dart';
import '../models/chat_message.dart';
import 'supabase_service.dart';

class RagService {
  final SupabaseService _supabaseService;

  // URL da Cloud Function que orquestra o RAG
  // TODO: Substituir pela URL real da sua Cloud Function
  static const String _ragEndpoint =
      'https://us-central1-YOUR_PROJECT.cloudfunctions.net/ragQuery';

  RagService({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  /// Envia uma pergunta ao pipeline RAG e retorna a resposta do agente.
  ///
  /// O fluxo:
  /// 1. Envia query para Cloud Function
  /// 2. Cloud Function gera embedding, busca no Supabase, e gera resposta via LLM
  /// 3. Retorna ChatMessage com conteudo e fontes
  Future<ChatMessage> query({
    required String messageId,
    required String question,
    String? raceId,
    String? category,
    String? sessionId,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    try {
      final body = {
        'question': question,
        'race_id': raceId,
        'category': category,
        'language': 'pt',
        'max_results': 10,
        'conversation_history': conversationHistory
            .where((m) => !m.isLoading && m.error == null)
            .take(10)
            .map((m) => {
                  'role': m.role.name,
                  'content': m.content,
                })
            .toList(),
      };

      final response = await http
          .post(
            Uri.parse(_ragEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final sources = (data['sources'] as List?)
                ?.map((s) =>
                    KnowledgeChunk.fromMap(Map<String, dynamic>.from(s)))
                .toList() ??
            [];

        final agentType = data['agent_type'] != null
            ? AgentType.values.firstWhere(
                (e) => e.name == data['agent_type'],
                orElse: () => AgentType.general,
              )
            : AgentType.general;

        return ChatMessage.assistant(
          id: messageId,
          content: data['answer'] ?? 'Desculpe, nao consegui encontrar uma resposta.',
          agentType: agentType,
          sources: sources,
          sessionId: sessionId,
        );
      } else {
        return ChatMessage.error(
          id: messageId,
          error: 'Erro ao consultar o assistente (${response.statusCode})',
          sessionId: sessionId,
        );
      }
    } catch (e) {
      return ChatMessage.error(
        id: messageId,
        error: 'Erro de conexao: $e',
        sessionId: sessionId,
      );
    }
  }

  /// Busca chunks de conhecimento diretamente no Supabase
  /// (sem passar pelo LLM - util para listar dicas de uma categoria)
  Future<List<KnowledgeChunk>> getKnowledge({
    required String raceId,
    KnowledgeCategory? category,
    int limit = 20,
  }) async {
    if (category != null) {
      return _supabaseService.getChunksByCategory(
        category,
        raceId: raceId,
        limit: limit,
      );
    }
    return _supabaseService.getChunksByRace(raceId);
  }

  /// Retorna as categorias disponíveis para uma corrida
  /// com a contagem de chunks em cada uma
  Future<Map<KnowledgeCategory, int>> getAvailableCategories(
      String raceId) async {
    final counts = await _supabaseService.getCategoryCountsByRace(raceId);
    return counts.map(
      (key, value) => MapEntry(KnowledgeCategory.fromDbValue(key), value),
    );
  }

  /// Retorna sugestoes de perguntas baseadas na corrida
  List<String> getSuggestions(String? raceId, String? raceName) {
    final name = raceName ?? 'esta corrida';
    return [
      'Como e a altimetria de $name?',
      'Onde me hospedar perto de $name?',
      'Melhores restaurantes na regiao?',
      'Que cuidados devo tomar?',
      'O que vem no kit da prova?',
      'Vale a pena comprar algo na regiao?',
      'Existem pacotes de viagem?',
      'Pontos turisticos para visitar?',
    ];
  }
}
