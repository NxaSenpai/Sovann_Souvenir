import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';

class _QuizQuestion {
  final String question;
  final String subtitle;
  final List<String> options;
  const _QuizQuestion({
    required this.question,
    this.subtitle = '',
    required this.options,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _step = 0;
  final _answers = <int>[];

  final _questions = const [
    _QuizQuestion(
      question: 'Who is this gift for?',
      subtitle: 'We\'ll tailor recommendations to their taste.',
      options: ['Her', 'Him', 'A couple', 'Myself'],
    ),
    _QuizQuestion(
      question: 'What is your budget?',
      subtitle: 'We have beautiful options at every price.',
      options: ['Under \$20', '\$20–\$50', '\$50–\$100', 'Over \$100'],
    ),
    _QuizQuestion(
      question: 'What type of gift?',
      subtitle: 'Choose a category that inspires you.',
      options: ['Wearable', 'Decorative', 'Edible', 'Collectible'],
    ),
    _QuizQuestion(
      question: 'Your experience with Cambodian crafts?',
      subtitle: 'This helps us match the perfect piece for you.',
      options: ['Just discovering', 'Somewhat familiar', 'Very familiar', 'I\'m a collector'],
    ),
    _QuizQuestion(
      question: 'What kind of experience are you seeking?',
      subtitle: 'Every piece tells a story — what story speaks to you?',
      options: ['Authentic & traditional', 'Modern & fusion', 'Luxurious & premium', 'Everyday & casual'],
    ),
  ];

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
    if (_step == _questions.length) {
      return _buildResults();
    }
    return _buildQuestion();
  }

  Widget _buildQuestion() {
    final q = _questions[_step];
    final progress = (_step + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 0) {
              context.pop();
            } else {
              setState(() { _step--; _answers.removeLast(); });
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // --- Progress ---
          Row(children: [
            Text('Step ${_step + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gold)),
            const Spacer(),
            Text('${(_step + 1)} of ${_questions.length}', style: const TextStyle(fontSize: 13, color: AppColors.warmGray)),
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
              color: AppColors.ivory,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(q.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3)),
              if (q.subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(q.subtitle, style: const TextStyle(fontSize: 15, color: AppColors.warmGray, height: 1.4)),
              ],
            ]),
          ),

          const SizedBox(height: 28),

          // --- Options ---
          Expanded(
            child: ListView.separated(
              itemCount: q.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _optionTile(i, q.options[i]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _optionTile(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _answers.add(index);
          _step++;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGray, width: 1.5),
        ),
        child: Row(children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warmGray.withOpacity(0.4), width: 2),
            ),
            child: const SizedBox.shrink(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          ),
          Icon(Icons.chevron_right, color: AppColors.warmGray.withOpacity(0.5), size: 22),
        ]),
      ),
    );
  }

  Widget _buildResults() {
    final category = _categoryFromAnswers();
    final recs = MockRepository.instance.byCategory(category);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(children: [
          // --- Header ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withOpacity(0.15), AppColors.ivory],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Text('🎁', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('We found your perfect gifts!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text('Based on your answers, here\'s what we recommend.',
                  style: TextStyle(fontSize: 14, color: AppColors.warmGray),
                  textAlign: TextAlign.center),
            ]),
          ),

          const SizedBox(height: 24),

          // --- Results ---
          Expanded(
            child: recs.isEmpty
                ? Center(
                    child: Text('No recommendations yet — try a different combination.',
                        style: TextStyle(fontSize: 15, color: AppColors.warmGray),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.lightGray, width: 1),
                          ),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(p.images.first,
                                  width: 64, height: 64, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text('\$${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 16)),
                              ]),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_forward, color: AppColors.gold, size: 20),
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
              label: const Text('Retake Quiz', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
