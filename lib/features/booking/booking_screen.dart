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
        _StepIndicator(currentStep: booking.step, steps: steps),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your item', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
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
        Text('Gift wrapping', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Choose how your item will be presented.',
            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 20),
        _OptionCard(
          selected: b.giftWrap,
          onTap: () => ref.read(bookingProvider.notifier).setGiftWrap(true),
          icon: Icons.card_giftcard,
          title: 'Yes, wrap it beautifully',
          subtitle: 'Hand-wrapped in traditional Khmer paper with a silk ribbon',
        ),
        const SizedBox(height: 12),
        _OptionCard(
          selected: !b.giftWrap,
          onTap: () => ref.read(bookingProvider.notifier).setGiftWrap(false),
          icon: Icons.inventory_2_outlined,
          title: 'No gift wrap',
          subtitle: 'Your item will be delivered in its original packaging',
        ),
      ]),
    );
  }

  Widget _buildStep2(BuildContext context, BookingState b) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Personal message', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Add a heartfelt note (optional).',
            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: b.personalMessage,
          maxLines: 6,
          maxLength: 200,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Write your message here...',
            hintStyle: TextStyle(color: AppColors.lightGray),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
          onChanged: (v) => ref.read(bookingProvider.notifier).setMessage(v),
        ),
      ]),
    );
  }

  Widget _buildStep3(BuildContext context, BookingState b) {
    final slots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Delivery date & time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Select your preferred delivery slot.',
            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGray),
          ),
          padding: const EdgeInsets.all(8),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 60)),
            focusedDay: b.deliveryDate ?? DateTime.now().add(const Duration(days: 3)),
            selectedDayPredicate: (day) => isSameDay(b.deliveryDate, day),
            onDaySelected: (selected, _) =>
                ref.read(bookingProvider.notifier).setDeliveryDate(selected),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal),
              leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.charcoal),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.charcoal),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), shape: BoxShape.circle),
              todayTextStyle: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              defaultTextStyle: const TextStyle(color: AppColors.charcoal),
              weekendTextStyle: const TextStyle(color: AppColors.warmGray),
              outsideTextStyle: const TextStyle(color: AppColors.lightGray),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Available time slots', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: slots.map((slot) {
            final selected = b.timeSlot == slot;
            return GestureDetector(
              onTap: () => ref.read(bookingProvider.notifier).setTimeSlot(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.gold : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: selected ? AppColors.gold : AppColors.lightGray),
                ),
                child: Text(slot, style: TextStyle(
                  color: selected ? Colors.white : AppColors.charcoal,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                )),
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

        const SizedBox(height: 24),

        // Booking reference
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: Row(children: [
            Icon(Icons.receipt_long_outlined, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Booking #${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('We\'ll confirm availability within 24 hours',
                    style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
              ]),
            ),
            Icon(Icons.copy, color: AppColors.gold, size: 18),
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

  Widget _detailRow(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.warmGray),
      const SizedBox(width: 12),
      SizedBox(width: 80, child: Text(label,
          style: const TextStyle(color: AppColors.warmGray, fontSize: 14))),
      Expanded(child: Text(value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
    ],
  );
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

class _OptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  const _OptionCard({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.lightGray,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: selected ? AppColors.gold.withOpacity(0.12) : AppColors.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: selected ? AppColors.gold : AppColors.warmGray, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.charcoal : AppColors.charcoal,
              )),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(
                fontSize: 12,
                color: AppColors.warmGray,
                height: 1.3,
              )),
            ]),
          ),
          if (selected)
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
        ]),
      ),
    );
  }
}
