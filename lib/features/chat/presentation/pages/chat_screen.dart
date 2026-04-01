import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/suggestion_chips.dart';

class ChatScreen extends StatefulWidget {
  final String? raceId;
  final String? raceName;

  const ChatScreen({
    super.key,
    this.raceId,
    this.raceName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatProvider _chatProvider;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _chatProvider = ChatProvider(
      raceId: widget.raceId,
      raceName: widget.raceName,
    );
    _chatProvider.addListener(_onChatUpdate);
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onChatUpdate);
    _chatProvider.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChatUpdate() {
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final message = text ?? _textController.text;
    if (message.trim().isEmpty) return;
    _chatProvider.sendMessage(message);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isEmbedded = widget.raceId != null;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assistente Runner Tips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.raceName != null)
              Text(
                widget.raceName!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_chatProvider.messages.isNotEmpty)
            IconButton(
              onPressed: () {
                _chatProvider.clearMessages();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Nova conversa',
            ),
        ],
      ),
      body: Column(
        children: [
          // Mensagens
          Expanded(
            child: _chatProvider.messages.isEmpty
                ? _buildEmptyState(isEmbedded)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(
                        message: _chatProvider.messages[index],
                      );
                    },
                  ),
          ),

          // Sugestoes (so aparecem quando nao ha mensagens)
          if (_chatProvider.messages.isEmpty)
            SuggestionChips(
              suggestions: _chatProvider.suggestions,
              onSelected: _sendMessage,
            ),

          // Input
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isEmbedded) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 40,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEmbedded
                  ? 'Tire suas duvidas sobre\n${widget.raceName}'
                  : 'Pergunte sobre qualquer\ncorrida ou trilha',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isEmbedded
                  ? 'Hospedagem, alimentacao, percurso, kit, compras e muito mais!'
                  : 'Nossos agentes especializados tem dicas de milhares de corredores.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Faça sua pergunta...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.primaryOrange),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppColors.gray50,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _chatProvider.isLoading
                  ? AppColors.gray300
                  : AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed:
                  _chatProvider.isLoading ? null : () => _sendMessage(),
              icon: Icon(
                _chatProvider.isLoading ? Icons.hourglass_top : Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
