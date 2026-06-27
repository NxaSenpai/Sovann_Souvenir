import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../services/chatbot_service.dart';
import '../../theme/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      segments: const ['Hello! 👋 I\'m Sovann, your gift assistant.\n\nTell me about the person you\'re shopping for, your budget, or the occasion — and I\'ll find the perfect Cambodian-crafted gift! 🎁'],
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(segments: [text], isUser: true));
      _isLoading = true;
      _textCtrl.clear();
    });
    _scrollDown();

    final history = _messages
        .where((m) => !m.isProduct)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.segments.join(''),
            })
        .toList();

    final reply = await ChatbotService.sendChat(history);
    final segments = ChatMessageParser.parse(reply);

    setState(() {
      _messages.add(_ChatMessage(segments: segments, isUser: false));
      _isLoading = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold,
            child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
          SizedBox(width: 10),
          Text('Gift Assistant'),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _messages.length) return _typingIndicator(isDark);
              return _messageWidget(_messages[i], isDark);
            },
          ),
        ),
        _inputBar(isDark),
      ]),
    );
  }

  Widget _messageWidget(_ChatMessage msg, bool isDark) {
    if (msg.isUser) {
      // User messages: just text
      return _textBubble(msg.segments.join(''), true, isDark);
    }

    // Bot messages: text first, then product cards grouped below
    final textParts = msg.segments.where((s) => !s.startsWith('@')).join('').trim();
    final productIds = msg.segments.where((s) => s.startsWith('@')).map((s) => s.substring(1)).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textParts.isNotEmpty)
            _textBubble(textParts, false, isDark),
          if (productIds.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...productIds.map((id) => _productCard(id, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _textBubble(String text, bool isUser, bool isDark) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser
                ? AppColors.gold
                : isDark ? AppColors.darkCard : const Color(0xFFF4F3EF),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
              bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
            ),
          ),
          child: Text(
            text.trim(),
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: isUser ? Colors.white : (isDark ? AppColors.cream : AppColors.charcoal),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard(String productId, bool isDark) {
    final repo = MockRepository.instance;
    final product = repo.productsTr.firstWhere(
      (p) => p.id == productId,
      orElse: () => repo.productsTr.first,
    );

    return GestureDetector(
      onTap: () => context.push('/product/$productId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withAlpha(isDark ? 50 : 40)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withAlpha(isDark ? 25 : 15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: product.images.first,
              width: 56, height: 56,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 56, height: 56,
                color: isDark ? AppColors.darkSurface : AppColors.lightGray,
                child: const Icon(Icons.card_giftcard, color: AppColors.gold, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14,
                        color: isDark ? AppColors.cream : AppColors.charcoal)),
                const SizedBox(height: 4),
                Row(children: [
                  ...List.generate(5, (i) => Icon(
                      i < product.rating.floor() ? Icons.star : Icons.star_border,
                      size: 13, color: AppColors.gold)),
                  const SizedBox(width: 6),
                  Text(product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text('\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ]),
      ),
    );
  }

  Widget _typingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : const Color(0xFFF4F3EF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18),
            bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
          ),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
          SizedBox(width: 10),
          Text('Sovann is thinking...',
              style: TextStyle(fontSize: 13, color: AppColors.warmGray)),
        ]),
      ),
    );
  }

  Widget _inputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(top: BorderSide(
            color: isDark ? AppColors.darkCard : const Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask about gifts...',
                hintStyle: TextStyle(color: AppColors.warmGray.withAlpha(160)),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : _send,
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _isLoading ? AppColors.gold.withAlpha(120) : AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ChatMessage {
  final List<String> segments;
  final bool isUser;
  bool get isProduct => segments.any((s) => s.startsWith('@'));
  const _ChatMessage({required this.segments, required this.isUser});
}
