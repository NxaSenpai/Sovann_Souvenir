import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  late List<Map<String, String>> _pages;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _pages = [
      {'emoji': '🏺', 'title': l10n.onboardingCraftedTitle, 'sub': l10n.onboardingCraftedSub},
      {'emoji': '🎁', 'title': l10n.onboardingGiftTitle, 'sub': l10n.onboardingGiftSub},
      {'emoji': '🗺️', 'title': l10n.onboardingFindTitle, 'sub': l10n.onboardingFindSub},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: Column(children: [
        Align(alignment: Alignment.centerRight, child: TextButton(
            onPressed: _finish, child: Text(l10n.skip, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))))),
        Expanded(child: PageView.builder(
          controller: _controller,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: _pages.length,
          itemBuilder: (context, i) {
            final p = _pages[i];
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(p['emoji']!, style: const TextStyle(fontSize: 100)),
                const SizedBox(height: 32),
                Text(p['title']!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(p['sub']!, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), height: 1.6), textAlign: TextAlign.center),
              ]),
            );
          },
        )),
        SmoothPageIndicator(
          controller: _controller,
          count: _pages.length,
          effect: ExpandingDotsEffect(
            activeDotColor: AppColors.gold,
            dotColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            dotHeight: 8
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: _page == _pages.length - 1 ? _finish
                : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
            child: Text(_page == _pages.length - 1 ? l10n.getStarted : l10n.next, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),
      ])),
    );
  }
}