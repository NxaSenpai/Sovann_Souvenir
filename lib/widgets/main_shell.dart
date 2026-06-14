import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/generated/app_localizations.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/favorites'))  return 1;
    if (location.startsWith('/map'))        return 2;
    if (location.startsWith('/promotions')) return 3;
    if (location.startsWith('/settings'))   return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/');
            case 1: context.go('/favorites');
            case 2: context.go('/map');
            case 3: context.go('/promotions');
            case 4: context.go('/settings');
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined),   selectedIcon: const Icon(Icons.home),       label: l10n.home),
          NavigationDestination(icon: const Icon(Icons.favorite_outline), selectedIcon: const Icon(Icons.favorite),   label: l10n.saved),
          NavigationDestination(icon: const Icon(Icons.map_outlined),     selectedIcon: const Icon(Icons.map),        label: l10n.map),
          NavigationDestination(icon: const Icon(Icons.local_offer_outlined), selectedIcon: const Icon(Icons.local_offer), label: l10n.promos),
          NavigationDestination(icon: const Icon(Icons.settings_outlined),selectedIcon: const Icon(Icons.settings),   label: l10n.settings),
        ],
      ),
    );
  }
}