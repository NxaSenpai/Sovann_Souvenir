import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collections = MockRepository.instance.collectionsTr;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        title: Text(l10n.collections, style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      ),
      body: collections.isEmpty
          ? Center(child: Text('No collections', style: TextStyle(color: AppColors.warmGray)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: collections.length,
              itemBuilder: (context, i) {
                final col = collections[i];
                return GestureDetector(
                  onTap: () => context.push('/collection/${col.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(fit: StackFit.expand, children: [
                        CachedNetworkImage(imageUrl: col.coverImage, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withAlpha(200), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16, right: 16, bottom: 16,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(50)),
                              child: Text(col.tag, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 8),
                            Text(col.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(col.description, style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
