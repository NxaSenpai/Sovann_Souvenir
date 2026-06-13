import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/favorites'))  return 1;
    if (location.startsWith('/map'))        return 2;
    if (location.startsWith('/cart'))       return 3;
    if (location.startsWith('/settings'))   return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/');
            case 1: context.go('/favorites');
            case 2: context.go('/map');
            case 3: context.go('/cart');
            case 4: context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),   selectedIcon: Icon(Icons.home),       label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite),   label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.map_outlined),     selectedIcon: Icon(Icons.map),        label: 'Map'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.settings_outlined),selectedIcon: Icon(Icons.settings),   label: 'Settings'),
        ],
      ),
    );
  }
}