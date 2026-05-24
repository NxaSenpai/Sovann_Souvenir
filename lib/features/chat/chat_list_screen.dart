import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final artisans = MockRepository.instance.artisans;
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        itemCount: artisans.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final a = artisans[i];
          return ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(a.avatar)),
            title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(a.craft, style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
            trailing: const Text('Now', style: TextStyle(fontSize: 11, color: AppColors.warmGray)),
            onTap: () => context.push('/chat/${a.id}'),
          );
        },
      ),
    );
  }
}