import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/mock_repository.dart';
import '../../state/booking_provider.dart';
import '../../theme/app_colors.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String productId;
  const BookingScreen({super.key, required this.productId});
  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  @override
  void initState() {
    super.initState();
    final product = MockRepository.instance.products
        .firstWhere((p) => p.id == widget.productId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).setProduct(product);
    });
  }

  void _handleContinue(BookingState booking) {
    if (booking.step == 3) {
      if (booking.deliveryDate == null) {
        _showValidationToast('Please choose a delivery date from the calendar');
        return;
      }
      if (booking.timeSlot.isEmpty) {
        _showValidationToast('Please select a delivery time slot');
        return;
      }
    }
    ref.read(bookingProvider.notifier).nextStep();
  }

  void _showValidationToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.35,
          right: 16,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    final steps = ['Item', 'Gift Wrap', 'Message', 'Date', 'Confirm'];

    return Scaffold(
      appBar: AppBar(
        title: Text(steps[booking.step]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (booking.step == 0) context.pop();
            else ref.read(bookingProvider.notifier).prevStep();
          },
        ),
      ),
      body: Column(children: [
        _StepIndicator(steps: steps, currentStep: booking.step),

        Expanded(child: [
          _buildStep0(context, booking),
          _buildStep1(context, booking),
          _buildStep2(context, booking),
          _buildStep3(context, booking),
          _buildStep4(context, booking),
        ][booking.step]),
        if (booking.step < 4)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: ElevatedButton(
              onPressed: () => _handleContinue(booking),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
      ]),
    );
  }

  Widget _buildStep0(BuildContext context, BookingState b) {
    final p = b.product;
    if (p == null) return const SizedBox();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGray),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(p.images.first, width: 72, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('\$${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
              ]),
            ),
            const Icon(Icons.check_circle, color: AppColors.gold, size: 28),
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You\'re booking a custom order. We\'ll confirm availability within 24 hours.',
                style: TextStyle(fontSize: 13, color: AppColors.warmGray, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStep1(BuildContext context, BookingState b) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Would you like gift wrapping?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Choose a wrapping option for your order.', style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 24),
        _giftWrapOption(
          context, b,
          icon: Icons.card_giftcard,
          title: 'Gift Wrap',
          subtitle: 'Signature Khmer silk-inspired wrapping with a gold ribbon',
          value: true,
          price: '\$5.99',
        ),
        const SizedBox(height: 12),
        _giftWrapOption(
          context, b,
          icon: Icons.inventory_2_outlined,
          title: 'No Gift Wrap',
          subtitle: 'Item will be packaged in a standard branded box',
          value: false,
        ),
      ]),
    );
  }

  Widget _giftWrapOption(
    BuildContext context, BookingState b, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    String? price,
  }) {
    final selected = b.giftWrap == value;
    return GestureDetector(
      onTap: () => ref.read(bookingProvider.notifier).setGiftWrap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withOpacity(0.08) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.lightGray,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: selected ? AppColors.gold.withOpacity(0.12) : AppColors.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: selected ? AppColors.gold : AppColors.warmGray, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: selected ? AppColors.charcoal : AppColors.charcoal,
                )),
                if (price != null) ...[
                  const SizedBox(width: 8),
                  Text(price, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold,
                  )),
                ],
              ]),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.warmGray, height: 1.3)),
            ]),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: selected ? 24 : 20,
            height: selected ? 24 : 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.gold : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.lightGray,
                width: selected ? 0 : 2,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ]),
      ),
    );
  }

  Widget _buildStep2(BuildContext context, BookingState b) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Personal message', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Add a heartfelt note to accompany your gift (optional).',
            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 20),
        Text('Quick templates', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warmGray)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _messageTemplates.map((t) => GestureDetector(
            onTap: () => ref.read(bookingProvider.notifier).setMessage(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: b.personalMessage == t ? AppColors.gold.withOpacity(0.12) : AppColors.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: b.personalMessage == t ? AppColors.gold : Colors.transparent,
                ),
              ),
              child: Text(t, style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: b.personalMessage == t ? AppColors.goldDark : AppColors.warmGray,
              )),
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),
        // Message input
        TextFormField(
          initialValue: b.personalMessage,
          maxLines: 5,
          maxLength: 200,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Or write your own message...',
            hintStyle: TextStyle(color: AppColors.lightGray),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterStyle: TextStyle(fontSize: 12, color: AppColors.warmGray),
          ),
          onChanged: (v) => ref.read(bookingProvider.notifier).setMessage(v),
        ),
        if (b.personalMessage.isNotEmpty) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldLight.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.auto_stories, size: 16, color: AppColors.gold.withOpacity(0.7)),
                const SizedBox(width: 8),
                Text('Message preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warmGray)),
              ]),
              const SizedBox(height: 10),
              Text(b.personalMessage, style: const TextStyle(
                fontSize: 14, height: 1.5, fontStyle: FontStyle.italic, color: AppColors.charcoal,
              )),
            ]),
          ),
        ],
      ]),
    );
  }

  static const _messageTemplates = [
    'Happy Birthday! Wishing you a wonderful day.',
    'Thank you for everything. I truly appreciate you.',
    'I love you more than words can say.',
    'Congratulations on your special day!',
    'Thinking of you always. With love.',
  ];

  Widget _buildStep3(BuildContext context, BookingState b) {
    final slots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Date section
        Row(children: [
          Icon(Icons.calendar_month, size: 18, color: AppColors.goldDark),
          const SizedBox(width: 8),
          Text('Select delivery date', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGray),
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 60)),
            focusedDay: b.deliveryDate ?? DateTime.now().add(const Duration(days: 3)),
            selectedDayPredicate: (day) => isSameDay(b.deliveryDate, day),
            onDaySelected: (selected, _) =>
                ref.read(bookingProvider.notifier).setDeliveryDate(selected),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppColors.gold.withOpacity(0.3), shape: BoxShape.circle),
              defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              outsideTextStyle: TextStyle(color: AppColors.lightGray, fontSize: 13),
              cellMargin: const EdgeInsets.all(4),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
              formatButtonVisible: false,
              leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
              rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),

        // Selected date summary
        if (b.deliveryDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(Icons.check_circle, size: 16, color: AppColors.gold),
              const SizedBox(width: 8),
              Text('Selected: ', style: TextStyle(fontSize: 13, color: AppColors.warmGray)),
              Text(
                '${b.deliveryDate!.day}/${b.deliveryDate!.month}/${b.deliveryDate!.year}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 24),
        const Divider(color: AppColors.lightGray, height: 1),
        const SizedBox(height: 20),

        // Time slots section
        Row(children: [
          Icon(Icons.schedule, size: 18, color: AppColors.goldDark),
          const SizedBox(width: 8),
          Text('Available time slots', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 4),
        Text('Choose a preferred delivery time.',
            style: TextStyle(fontSize: 13, color: AppColors.warmGray)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: slots.map((slot) {
            final selected = b.timeSlot == slot;
            return GestureDetector(
              onTap: () => ref.read(bookingProvider.notifier).setTimeSlot(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.gold : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: selected ? AppColors.gold : AppColors.lightGray,
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.access_time, size: 14, color: Colors.white),
                    ),
                  Text(slot, style: TextStyle(
                    color: selected ? Colors.white : AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _buildStep4(BuildContext context, BookingState b) {
    final p = b.product;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(children: [
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.gold, size: 56),
        ),
        const SizedBox(height: 16),
        const Text('Booking Confirmed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Your order has been placed successfully.',
            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 28),

        // Product summary card
        if (p != null)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGray),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(p.images.first, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('\$${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
                ]),
              ),
            ]),
          ),

        const SizedBox(height: 16),

        // Order details
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGray),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Order Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _detailRow(Icons.card_giftcard, 'Gift Wrap', b.giftWrap ? 'Yes' : 'No'),
            if (b.personalMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              _detailRow(Icons.edit_note, 'Message', b.personalMessage),
            ],
            const Divider(height: 28, color: AppColors.lightGray),
            const Text('Delivery', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (b.deliveryDate != null) _detailRow(
              Icons.calendar_today, 'Date',
              '${b.deliveryDate!.day}/${b.deliveryDate!.month}/${b.deliveryDate!.year}',
            ),
            if (b.timeSlot.isNotEmpty) ...[
              const SizedBox(height: 16),
              _detailRow(Icons.schedule, 'Time', b.timeSlot),
            ],
          ]),
        ),

        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(bookingProvider.notifier).reset();
            context.go('/');
          },
          icon: const Icon(Icons.home_outlined, size: 20),
          label: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.warmGray),
        const SizedBox(width: 12),
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.warmGray))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
      ]),
    );
  }

}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(children: [
        Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              final stepBefore = i ~/ 2;
              final active = stepBefore < currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  color: active ? AppColors.gold : AppColors.lightGray,
                ),
              );
            }
            final step = i ~/ 2;
            final isActive = step <= currentStep;
            final isCurrent = step == currentStep;
            return Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 36 : 30,
                height: isCurrent ? 36 : 30,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.gold : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppColors.gold : AppColors.lightGray,
                    width: isCurrent ? 2.5 : 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.warmGray,
                      fontSize: isCurrent ? 13 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(steps[step], style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.charcoal : AppColors.warmGray,
              )),
            ]);
          }),
        ),
      ]),
    );
  }
}


