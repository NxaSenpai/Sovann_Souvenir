import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final artisans = MockRepository.instance.artisans;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.messages)),
      body: ListView.separated(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        itemCount: artisans.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final a = artisans[i];
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(a.avatar)),
            title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(a.craft, style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.cream.withOpacity(0.7) : AppColors.warmGray,
            )),
            trailing: Text(l10n.now, style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.cream.withOpacity(0.7) : AppColors.warmGray,
            )),
            onTap: () => context.push('/chat/${a.id}'),
          );
        },
      ),
    );
  }
}