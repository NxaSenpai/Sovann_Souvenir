import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';

class _Message {
  final String text;
  final bool isMe;
  final DateTime time;
  _Message({required this.text, required this.isMe, required this.time});
}

class ChatThreadScreen extends StatefulWidget {
  final String artisanId;
  const ChatThreadScreen({super.key, required this.artisanId});
  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _controller = TextEditingController();
  bool _isTyping = false;
  final _scrollController = ScrollController();

  final List<_Message> _messages = [
    _Message(text: "Hello! I'm interested in your crafts.", isMe: true, time: DateTime.now().subtract(const Duration(minutes: 10))),
    _Message(text: "Thank you for reaching out! Which items interest you?", isMe: false, time: DateTime.now().subtract(const Duration(minutes: 9))),
    _Message(text: "I love the krama scarves. Do you ship internationally?", isMe: true, time: DateTime.now().subtract(const Duration(minutes: 5))),
    _Message(text: "Yes, we ship worldwide! Delivery takes 7–14 days. 🙏", isMe: false, time: DateTime.now().subtract(const Duration(minutes: 4))),
  ];

  final _autoReplies = [
    "Thank you for your message! 🙏",
    "Great choice! This item is very popular with our customers.",
    "I handcraft every piece with love and care.",
    "We use only the finest natural materials from Cambodia.",
    "Would you like a custom size or color?",
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMe: true, time: DateTime.now()));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final reply = _autoReplies[_messages.length % _autoReplies.length];
      setState(() {
        _isTyping = false;
        _messages.add(_Message(text: reply, isMe: false, time: DateTime.now()));
      });
      _scrollToBottom();
    });
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

  @override
  Widget build(BuildContext context) {
    final artisan = MockRepository.instance.artisanById(widget.artisanId);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: artisan == null ? const Text('Chat') : Row(children: [
          CircleAvatar(backgroundImage: NetworkImage(artisan.avatar), radius: 16),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(artisan.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text('Online', style: TextStyle(fontSize: 11, color: Colors.green.shade400)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, i) {
              if (_isTyping && i == _messages.length) {
                return Row(children: [
                  const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 14)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest, 
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Row(children: List.generate(3, (j) => AnimatedContainer(
                      duration: Duration(milliseconds: 400 + j * 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), 
                        shape: BoxShape.circle
                      ),
                    ))),
                  ),
                ]);
              }
              final msg = _messages[i];
              return Align(
                alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: msg.isMe ? AppColors.gold : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                      bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(msg.text, style: TextStyle(
                    color: msg.isMe ? Colors.white : Theme.of(context).colorScheme.onSurface
                  )),
                ),
              );
            },
          ),
        ),
        // Input bar
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            IconButton(icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), onPressed: () {}),
            Expanded(child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.gold,
              child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _send),
            ),
          ]),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}