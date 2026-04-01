import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/services/rag_service.dart';

class ChatProvider extends ChangeNotifier {
  final RagService _ragService;
  final String? raceId;
  final String? raceName;

  ChatSession? _session;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatProvider({
    RagService? ragService,
    this.raceId,
    this.raceName,
  }) : _ragService = ragService ?? RagService() {
    _initSession();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  ChatSession? get session => _session;

  List<String> get suggestions =>
      _ragService.getSuggestions(raceId, raceName);

  void _initSession() {
    const uuid = Uuid();
    _session = ChatSession.create(
      id: uuid.v4(),
      raceId: raceId,
      raceName: raceName,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    const uuid = Uuid();

    // Adicionar mensagem do usuario
    final userMessage = ChatMessage.user(
      id: uuid.v4(),
      content: text.trim(),
      raceId: raceId,
      sessionId: _session?.id,
    );
    _messages.add(userMessage);

    // Adicionar placeholder de loading
    final loadingId = uuid.v4();
    _messages.add(ChatMessage.loading(
      id: loadingId,
      sessionId: _session?.id,
    ));
    _isLoading = true;
    notifyListeners();

    // Consultar RAG
    final response = await _ragService.query(
      messageId: loadingId,
      question: text.trim(),
      raceId: raceId,
      sessionId: _session?.id,
      conversationHistory: _messages
          .where((m) => !m.isLoading && m.error == null)
          .toList(),
    );

    // Substituir loading pela resposta
    final loadingIndex = _messages.indexWhere((m) => m.id == loadingId);
    if (loadingIndex != -1) {
      _messages[loadingIndex] = response;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _initSession();
    notifyListeners();
  }
}
