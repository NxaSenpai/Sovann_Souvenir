import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = [
    {'emoji': '🏺', 'title': 'Crafted in Cambodia', 'sub': 'Discover handmade gifts by Cambodian artisans, each with a unique story.'},
    {'emoji': '🎁', 'title': 'Gift with Meaning', 'sub': 'Order with personalized messages, gift wrapping, and flexible delivery.'},
    {'emoji': '🗺️', 'title': 'Find Artisan Shops', 'sub': 'Locate physical ateliers and markets across Cambodia.'},
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(child: Column(children: [
        Align(alignment: Alignment.centerRight, child: TextButton(
            onPressed: _finish, child: const Text('Skip', style: TextStyle(color: AppColors.warmGray)))),
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
                Text(p['title']!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.charcoal), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(p['sub']!, style: const TextStyle(fontSize: 15, color: AppColors.warmGray, height: 1.6), textAlign: TextAlign.center),
              ]),
            );
          },
        )),
        SmoothPageIndicator(
          controller: _controller,
          count: _pages.length,
          effect: const ExpandingDotsEffect(activeDotColor: AppColors.gold, dotHeight: 8),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton(
            onPressed: _page == _pages.length - 1 ? _finish
                : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
            child: Text(_page == _pages.length - 1 ? 'Get Started' : 'Next', style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),
      ])),
    );
  }
}