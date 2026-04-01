import 'package:equatable/equatable.dart';
import 'knowledge_chunk.dart';

enum MessageRole { user, assistant, system }

enum AgentType {
  router,
  raceInfo,
  travel,
  safety,
  localExpert,
  training,
  general;

  String get label {
    switch (this) {
      case AgentType.router:
        return 'Router';
      case AgentType.raceInfo:
        return 'Info da Corrida';
      case AgentType.travel:
        return 'Viagem';
      case AgentType.safety:
        return 'Seguranca';
      case AgentType.localExpert:
        return 'Especialista Local';
      case AgentType.training:
        return 'Treinamento';
      case AgentType.general:
        return 'Geral';
    }
  }

  String get icon {
    switch (this) {
      case AgentType.router:
        return '🔀';
      case AgentType.raceInfo:
        return '🏁';
      case AgentType.travel:
        return '✈️';
      case AgentType.safety:
        return '🛡️';
      case AgentType.localExpert:
        return '📍';
      case AgentType.training:
        return '🏋️';
      case AgentType.general:
        return '💡';
    }
  }
}

class ChatMessage extends Equatable {
  final String id;
  final String? sessionId;
  final MessageRole role;
  final String content;
  final AgentType? agentType;
  final String? raceId;
  final List<KnowledgeChunk> sources;
  final bool isLoading;
  final String? error;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    this.sessionId,
    required this.role,
    required this.content,
    this.agentType,
    this.raceId,
    this.sources = const [],
    this.isLoading = false,
    this.error,
    required this.createdAt,
  });

  factory ChatMessage.user({
    required String id,
    required String content,
    String? raceId,
    String? sessionId,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: MessageRole.user,
      content: content,
      raceId: raceId,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.loading({required String id, String? sessionId}) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: MessageRole.assistant,
      content: '',
      isLoading: true,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.assistant({
    required String id,
    required String content,
    AgentType? agentType,
    List<KnowledgeChunk> sources = const [],
    String? sessionId,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: MessageRole.assistant,
      content: content,
      agentType: agentType,
      sources: sources,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.error({
    required String id,
    required String error,
    String? sessionId,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: MessageRole.assistant,
      content: '',
      error: error,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      sessionId: map['session_id'],
      role: MessageRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => MessageRole.user,
      ),
      content: map['content'] ?? '',
      agentType: map['agent_type'] != null
          ? AgentType.values.firstWhere(
              (e) => e.name == map['agent_type'],
              orElse: () => AgentType.general,
            )
          : null,
      raceId: map['race_id'],
      sources: (map['sources'] as List?)
              ?.map((s) => KnowledgeChunk.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role.name,
      'content': content,
      'agent_type': agentType?.name,
      'race_id': raceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    String? content,
    AgentType? agentType,
    List<KnowledgeChunk>? sources,
    bool? isLoading,
    String? error,
  }) {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      role: role,
      content: content ?? this.content,
      agentType: agentType ?? this.agentType,
      raceId: raceId,
      sources: sources ?? this.sources,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        role,
        content,
        agentType,
        raceId,
        sources,
        isLoading,
        error,
        createdAt,
      ];
}

class ChatSession extends Equatable {
  final String id;
  final String? userId;
  final String? raceId;
  final String? raceName;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    this.userId,
    this.raceId,
    this.raceName,
    required this.title,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.create({
    required String id,
    String? userId,
    String? raceId,
    String? raceName,
  }) {
    final title = raceName != null ? 'Chat sobre $raceName' : 'Nova conversa';
    return ChatSession(
      id: id,
      userId: userId,
      raceId: raceId,
      raceName: raceName,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, raceId, title, createdAt];
}
