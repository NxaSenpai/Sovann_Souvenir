import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';

class _QuizQuestion {
  final String question;
  final List<String> options;
  const _QuizQuestion({required this.question, required this.options});
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
    _QuizQuestion(question: 'Who is this gift for?', options: ['Her', 'Him', 'A couple', 'Myself']),
    _QuizQuestion(question: 'What is your budget?', options: ['Under \$20', '\$20–\$50', '\$50–\$100', 'Over \$100']),
    _QuizQuestion(question: 'What type of gift?', options: ['Wearable', 'Decorative', 'Edible', 'Collectible']),
    _QuizQuestion(question: 'What is the occasion?', options: ['Birthday', 'Wedding', 'Souvenir', 'Just because']),
  ];

  String _categoryFromAnswers() {
    // Simple mapping: if "Her" + wearable → textile/jewelry; "Him" + edible → edible; etc.
    final giftType = _answers.length > 2 ? _answers[2] : 0;
    switch (giftType) {
      case 0: return _answers[0] == 0 ? 'textile' : 'silver';
      case 1: return 'wood';
      case 2: return 'edible';
      case 3: return 'jewelry';
      default: return 'textile';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _questions.length) {
      final category = _categoryFromAnswers();
      final recs = MockRepository.instance.byCategory(category);

      return Scaffold(
        appBar: AppBar(title: const Text('Your Recommendations')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('🎁', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('We found the perfect gifts for you!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recs.length,
              itemBuilder: (context, i) {
                final p = recs[i];
                return GestureDetector(
                  onTap: () => context.push('/product/${p.id}'),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                          child: Image.network(p.images.first, width: 60, height: 60, fit: BoxFit.cover)),
                      title: Text(p.name),
                      subtitle: Text('\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => setState(() { _step = 0; _answers.clear(); }),
              child: const Text('Retake Quiz'),
            ),
          ),
        ]),
      );
    }

    final q = _questions[_step];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_step + 1} of ${_questions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 0) context.pop();
            else setState(() { _step--; _answers.removeLast(); });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: _step / _questions.length,
              backgroundColor: AppColors.lightGray,
              color: AppColors.gold,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 32),
          Text(q.question, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 32),
          ...q.options.asMap().entries.map((e) => GestureDetector(
            onTap: () {
              setState(() {
                _answers.add(e.key);
                _step++;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
              ),
              child: Row(children: [
                Text(e.value, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.warmGray),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}