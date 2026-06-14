import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/rating_stars.dart';

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
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final _questions = const [
    _QuizQuestion(
      question: 'Who is this gift for?',
      subtitle: "We'll tailor recommendations to their taste.",
      icon: Icons.person_pin_rounded,
      options: ['Her', 'Him', 'A couple', 'Myself'],
    ),
    _QuizQuestion(
      question: 'What is your budget?',
      subtitle: 'We have beautiful options at every price.',
      icon: Icons.attach_money_rounded,
      options: ['Under \$20', '\$20–\$50', '\$50–\$100', 'Over \$100'],
    ),
    _QuizQuestion(
      question: 'What type of gift?',
      subtitle: 'Choose a category that inspires you.',
      icon: Icons.card_giftcard_rounded,
      options: ['Wearable', 'Decorative', 'Edible', 'Collectible'],
    ),
    _QuizQuestion(
      question: 'Your experience with Cambodian crafts?',
      subtitle: 'This helps us match the perfect piece for you.',
      icon: Icons.psychology_rounded,
      options: ['Just discovering', 'Somewhat familiar', 'Very familiar', "I'm a collector"],
    ),
    _QuizQuestion(
      question: 'What kind of experience are you seeking?',
      subtitle: 'Every piece tells a story — what story speaks to you?',
      icon: Icons.auto_awesome_rounded,
      options: ['Authentic & traditional', 'Modern & fusion', 'Luxurious & premium', 'Everyday & casual'],
    ),
  ];

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
    if (_step == _questions.length) return _buildResults();
    return _buildQuestion();
  }

  Widget _buildQuestion() {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(children: [
            // Progress
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${_step + 1} of ${_questions.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold)),
              ),
              const Spacer(),
              Row(
                children: List.generate(_questions.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(left: 4),
                  width: i <= _step ? 20 : 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= _step ? AppColors.gold : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ]),
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
      ),
    );
  }

  Widget _optionTile(int index, String label) {
    return GestureDetector(
      onTap: () => _goNext(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGray.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
            child: Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ),
        ]),
      ),
    );
  }

  Widget _buildResults() {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(children: [
            // Celebration header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, Color(0xFFD4A84B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(children: [
                const Icon(Icons.celebration_rounded, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text("We've got your match!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Handpicked gifts tailored to your preferences.',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                    textAlign: TextAlign.center),
              ]),
            ),
            const SizedBox(height: 24),

            // Results list
            Expanded(
              child: recs.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off_rounded, size: 48, color: AppColors.warmGray.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('No recommendations found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.warmGray)),
                        const SizedBox(height: 4),
                        Text('Try a different combination.',
                            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
                      ]),
                    )
                  : ListView.separated(
                      itemCount: recs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final p = recs[i];
                        return GestureDetector(
                          onTap: () => context.push('/product/${p.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Retake Quiz', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                onPressed: () {
                  setState(() { _step = 0; _answers.clear(); });
                  _fadeCtrl.forward(from: 0);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.charcoal,
                  side: BorderSide(color: AppColors.lightGray.withOpacity(0.8)),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
