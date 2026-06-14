import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

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
    _Message(text: '', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 10))),
    _Message(text: '', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 9))),
    _Message(text: '', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 5))),
    _Message(text: '', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 4))),
  ];

  List<String> _autoReplies = [];

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
    final l10n = AppLocalizations.of(context);
    final artisan = MockRepository.instance.artisanById(widget.artisanId);

    // Initialize localized content on first build
    if (_messages[0].text.isEmpty) {
      _messages[0] = _Message(text: l10n.chatSeed1, isMe: true, time: DateTime.now().subtract(const Duration(minutes: 10)));
      _messages[1] = _Message(text: l10n.chatSeed2, isMe: false, time: DateTime.now().subtract(const Duration(minutes: 9)));
      _messages[2] = _Message(text: l10n.chatSeed3, isMe: true, time: DateTime.now().subtract(const Duration(minutes: 5)));
      _messages[3] = _Message(text: l10n.chatSeed4, isMe: false, time: DateTime.now().subtract(const Duration(minutes: 4)));
      _autoReplies = [
        l10n.chatAutoReply1,
        l10n.chatAutoReply2,
        l10n.chatAutoReply3,
        l10n.chatAutoReply4,
        l10n.chatAutoReply5,
      ];
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: artisan == null ? Text(l10n.chat) : Row(children: [
          CircleAvatar(backgroundImage: NetworkImage(artisan.avatar), radius: 16),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(artisan.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Text(l10n.online, style: TextStyle(fontSize: 11, color: Colors.green.shade400)),
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
          padding: EdgeInsets.only(
            left: 12, right: 12,
            top: 8,
            bottom: 8 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(children: [
            IconButton(icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), onPressed: () {}),
            Expanded(child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: l10n.typeMessage,
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
      ]),
    );
  }
}