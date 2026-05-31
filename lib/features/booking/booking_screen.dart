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
        // Step indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) return Expanded(child: Container(height: 1, color: Theme.of(context).dividerColor));
              final step = i ~/ 2;
              final isActive = step <= booking.step;
              return CircleAvatar(
                radius: 14,
                backgroundColor: isActive ? AppColors.gold : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text('${step + 1}', style: TextStyle(
                    color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
                    fontSize: 11, fontWeight: FontWeight.w700)),
              );
            }),
          ),
        ),

        Expanded(child: [
          _buildStep0(context, booking),
          _buildStep1(context, booking),
          _buildStep2(context, booking),
          _buildStep3(context, booking),
          _buildStep4(context, booking),
        ][booking.step]),

        // Next button
        if (booking.step < 4)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => ref.read(bookingProvider.notifier).nextStep(),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
              child: const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
      ]),
    );
  }

  Widget _buildStep0(BuildContext context, BookingState b) {
    final p = b.product;
    if (p == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your item', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Card(child: ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(8),
              child: Image.network(p.images.first, width: 60, height: 60, fit: BoxFit.cover)),
          title: Text(p.name),
          subtitle: Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.gold)),
          trailing: const Icon(Icons.check_circle, color: AppColors.gold),
        )),
      ]),
    );
  }

  Widget _buildStep1(BuildContext context, BookingState b) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const Text('Would you like gift wrapping?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        ...[ {'label': 'Yes, wrap it beautifully 🎁', 'val': true},
          {'label': 'No gift wrap', 'val': false}].map((opt) =>
            GestureDetector(
              onTap: () => ref.read(bookingProvider.notifier).setGiftWrap(opt['val'] as bool),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: b.giftWrap == opt['val'] ? AppColors.gold : Theme.of(context).dividerColor,
                    width: b.giftWrap == opt['val'] ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: b.giftWrap == opt['val'] ? AppColors.gold.withOpacity(0.08) : null,
                ),
                child: Text(opt['label'] as String, style: const TextStyle(fontSize: 15)),
              ),
            ),
        ),
      ]),
    );
  }

  Widget _buildStep2(BuildContext context, BookingState b) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Personal message (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: b.personalMessage,
          maxLines: 5,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Write your heartfelt message here...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) => ref.read(bookingProvider.notifier).setMessage(v),
        ),
      ]),
    );
  }

  Widget _buildStep3(BuildContext context, BookingState b) {
    final slots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TableCalendar(
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
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
            formatButtonVisible: false,
            leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
            rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Time Slot', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: slots.map((slot) => GestureDetector(
            onTap: () => ref.read(bookingProvider.notifier).setTimeSlot(slot),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: b.timeSlot == slot ? AppColors.gold : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(slot, style: TextStyle(
                color: b.timeSlot == slot ? Colors.white : AppColors.gold,
                fontWeight: FontWeight.w600,
              )),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildStep4(BuildContext context, BookingState b) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Icon(Icons.check_circle, color: AppColors.gold, size: 80),
        const SizedBox(height: 16),
        const Text('Order Confirmed! 🎉', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        _confirmRow(context, 'Item', b.product?.name ?? ''),
        _confirmRow(context, 'Gift Wrap', b.giftWrap ? 'Yes' : 'No'),
        if (b.personalMessage.isNotEmpty) _confirmRow(context, 'Message', b.personalMessage),
        if (b.deliveryDate != null) _confirmRow(context, 'Delivery Date', '${b.deliveryDate!.day}/${b.deliveryDate!.month}/${b.deliveryDate!.year}'),
        if (b.timeSlot.isNotEmpty) _confirmRow(context, 'Time', b.timeSlot),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            ref.read(bookingProvider.notifier).reset();
            context.go('/');
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 54)),
          child: const Text('Back to Home'),
        ),
      ]),
    );
  }

  Widget _confirmRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );
}