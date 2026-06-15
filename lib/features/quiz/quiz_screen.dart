import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';
import '../../l10n/generated/app_localizations.dart';

class _QuizQuestion {
  final String question;
  final String subtitle;
  final IconData icon;
  final List<String> options;
  const _QuizQuestion({
    required this.question,
    this.subtitle = '',
    required this.icon,
    required this.options,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _step = 0;
  final _answers = <int>[];
  List<_QuizQuestion> _questions = [];
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  double get progress => _questions.isEmpty ? 0 : (_step + 1) / _questions.length;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _goNext(int answerIndex) {
    _fadeCtrl.reverse().then((_) {
      setState(() {
        _answers.add(answerIndex);
        _step++;
      });
      _fadeCtrl.forward();
    });
  }

  void _goBack() {
    _fadeCtrl.reverse().then((_) {
      setState(() {
        if (_step == 0) { context.pop(); return; }
        _step--;
        _answers.removeLast();
      });
      _fadeCtrl.forward();
    });
  }

  String _categoryFromAnswers() {
    final giftType = _answers.length > 2 ? _answers[2] : 0;
    final experience = _answers.length > 3 ? _answers[3] : 0;
    final base = switch (giftType) {
      0 => _answers[0] == 0 ? 'textile' : 'silver',
      1 => 'wood',
      2 => 'edible',
      3 => 'jewelry',
      _ => 'textile',
    };
    if (experience >= 2 && base == 'edible') return 'textile';
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Build localized questions on first pass
    if (_questions.isEmpty) {
      _questions = [
        _QuizQuestion(
          question: l10n.quizWho,
          subtitle: l10n.quizWhoSub,
          icon: Icons.person_outline,
          options: [l10n.quizHer, l10n.quizHim, l10n.quizCouple, l10n.quizMyself],
        ),
        _QuizQuestion(
          question: l10n.quizBudget,
          subtitle: l10n.quizBudgetSub,
          icon: Icons.attach_money,
          options: [l10n.quizAffordable, l10n.quizModerate, l10n.quizMidRange, l10n.quizPremium],
        ),
        _QuizQuestion(
          question: l10n.quizType,
          subtitle: l10n.quizTypeSub,
          icon: Icons.category_outlined,
          options: [l10n.quizWearable, l10n.quizDecorative, l10n.quizEdible, l10n.quizCollectible],
        ),
        _QuizQuestion(
          question: l10n.quizExperience,
          subtitle: l10n.quizExperienceSub,
          icon: Icons.explore_outlined,
          options: [l10n.quizDiscovering, l10n.quizSomewhat, l10n.quizVery, l10n.quizCollector],
        ),
        _QuizQuestion(
          question: l10n.quizSeeking,
          subtitle: l10n.quizSeekingSub,
          icon: Icons.search_outlined,
          options: [l10n.quizTraditional, l10n.quizModern, l10n.quizLuxurious, l10n.quizEveryday],
        ),
      ];
    }

    if (_step == _questions.length) {
      return _buildResults();
    }
    return _buildQuestion();
  }

  Widget _buildQuestion() {
    final l10n = AppLocalizations.of(context);
    final q = _questions[_step];

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.charcoal),
          onPressed: _goBack,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          24, 8, 24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // --- Progress ---
          Row(children: [
            Text('${l10n.step} ${_step + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gold)),
            const Spacer(),
            Text('${_step + 1} ${l10n.ofLabel} ${_questions.length}', style: const TextStyle(fontSize: 13, color: AppColors.warmGray)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lightGray,
              color: AppColors.gold,
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 40),

          // --- Question ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCard : AppColors.ivory,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q.question, style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, height: 1.3,
                color: Theme.of(context).colorScheme.onSurface,
              )),
              if (q.subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(q.subtitle, style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.cream.withOpacity(0.7) : AppColors.warmGray,
                  height: 1.4,
                )),
              ],
            ]),
          ),
          const SizedBox(height: 28),

          // Question card
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(children: [
                      Icon(q.icon, size: 44, color: AppColors.gold),
                      const SizedBox(height: 16),
                      Text(q.question,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
                          textAlign: TextAlign.center),
                      if (q.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(q.subtitle,
                            style: const TextStyle(fontSize: 14, color: AppColors.warmGray, height: 1.4),
                            textAlign: TextAlign.center),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  Expanded(
                    child: ListView.separated(
                      itemCount: q.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _optionTile(i, q.options[i]),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
    );
  }

  Widget _optionTile(int index, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _goNext(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkSurface : AppColors.lightGray,
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text('${index + 1}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            )),
            ),
          ]),
        ),
    );
  }

  Widget _buildResults() {
    final l10n = AppLocalizations.of(context);
    final category = _categoryFromAnswers();
    final recs = MockRepository.instance.byCategory(category);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.charcoal),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          24, 8, 24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(children: [
          // --- Header ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withOpacity(0.15),
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkCard : AppColors.ivory,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
              const Text('🎁', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(l10n.quizFound,
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(l10n.quizFoundSub,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.cream.withOpacity(0.7) : AppColors.warmGray,
                  ),
                  textAlign: TextAlign.center),
            ]),
          ),

          const SizedBox(height: 24),

          // --- Results ---
          Expanded(
            child: recs.isEmpty
                ? Center(
                    child: Text(l10n.quizNoResults,
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.cream.withOpacity(0.7) : AppColors.warmGray,
                        ),
                        textAlign: TextAlign.center),
                  )
                : ListView.separated(
                    itemCount: recs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = recs[i];
                      return GestureDetector(
                        onTap: () => context.push('/product/${p.id}'),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Row(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(p.images.first,
                                    width: 72, height: 72, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(p.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  RatingStars(rating: p.rating, size: 12),
                                  const SizedBox(height: 4),
                                  Text('\$${p.price.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 16)),
                                ]),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.gold, size: 20),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
            ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(l10n.retakeQuiz, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              onPressed: () => setState(() { _step = 0; _answers.clear(); }),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: BorderSide(color: AppColors.gold.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          ]),
        ),
    );
  }
}
