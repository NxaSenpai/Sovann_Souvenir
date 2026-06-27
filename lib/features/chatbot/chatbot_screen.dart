import 'package:flutter/material.dart';
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
      text: 'Hello! 👋 I\'m Sovann, your gift-shopping assistant.\n\n'
          'Tell me who you\'re shopping for or what kind of gift '
          'you have in mind, and I\'ll help you find the perfect '
          'Cambodian-crafted souvenir! 🎁',
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
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _textCtrl.clear();
    });
    _scrollDown();

    final history = _messages
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();

    final reply = await ChatbotService.sendChat(history);

    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false));
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
              if (i == _messages.length) {
                return _typingIndicator(isDark);
              }
              return _bubble(_messages[i], isDark);
            },
          ),
        ),
        _inputBar(isDark),
      ]),
    );
  }

  // ── Message bubble ──
  Widget _bubble(_ChatMessage msg, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser
              ? AppColors.gold
              : isDark
                  ? AppColors.darkCard
                  : const Color(0xFFF4F3EF),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: msg.isUser
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: msg.isUser
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: msg.isUser
                ? Colors.white
                : isDark
                    ? AppColors.cream
                    : AppColors.charcoal,
          ),
        ),
      ),
    );
  }

  // ── Typing indicator ──
  Widget _typingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : const Color(0xFFF4F3EF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Sovann is typing...',
              style: TextStyle(fontSize: 13, color: AppColors.warmGray),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input bar ──
  Widget _inputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCard : const Color(0xFFEEEEEE),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask about gifts...',
                hintStyle:
                    TextStyle(color: AppColors.warmGray.withAlpha(160)),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : _send,
            child: Container(
              width: 42,
              height: 42,
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
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}
