import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/profile_provider.dart';
import '../theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/favorites')) return 1;
    if (location.startsWith('/map')) return 2;
    if (location.startsWith('/orders')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final avatarUrl = ref.watch(avatarProvider);
    final current = _currentIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: current,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/');
            case 1: context.go('/favorites');
            case 2: context.go('/map');
            case 3: context.go('/orders');
            case 4: context.go('/profile');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.saved,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.map,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.orders,
          ),
          NavigationDestination(
            icon: avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 24, height: 24, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(Icons.person_outline),
                    ),
                  )
                : const Icon(Icons.person_outline),
            selectedIcon: avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(avatarUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
