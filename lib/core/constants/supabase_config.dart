class SupabaseConfig {
  // TODO: Substituir por suas credenciais do Supabase
  static const String url = 'https://YOUR_PROJECT.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';

  // Tabelas
  static const String knowledgeChunksTable = 'knowledge_chunks';
  static const String raceRoutesTable = 'race_routes';
  static const String chatHistoryTable = 'chat_history';

  // Funcoes RPC
  static const String searchKnowledgeRpc = 'search_knowledge';

  // Categorias de conhecimento
  static const List<String> categories = [
    'altimetry',
    'route',
    'problems',
    'accommodation',
    'food',
    'tourism',
    'safety',
    'shopping',
    'travel_package',
    'race_kit',
    'training',
    'general',
  ];
}
