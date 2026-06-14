import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/mock_repository.dart';
import '../../state/booking_provider.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

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
        _showValidationToast(AppLocalizations.of(context).chooseDeliveryDate);
        return;
      }
      if (booking.timeSlot.isEmpty) {
        _showValidationToast(AppLocalizations.of(context).selectTimeSlot);
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
    final l10n = AppLocalizations.of(context);
    final booking = ref.watch(bookingProvider);
    final steps = [l10n.stepItem, l10n.stepGiftWrap, l10n.stepMessage, l10n.stepDate, l10n.stepConfirm];

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
        if (booking.step < 4)
          Padding(
            padding: EdgeInsets.fromLTRB(
              20, 8, 20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: ElevatedButton(
              onPressed: () => _handleContinue(booking),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(l10n.continueButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
      ]),
    );
  }

  Widget _buildStep0(BuildContext context, BookingState b) {
    final l10n = AppLocalizations.of(context);
    final p = b.product;
    if (p == null) return const SizedBox();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.yourItem, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
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
                l10n.bookingNotice,
                style: TextStyle(fontSize: 13, color: AppColors.warmGray, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStep1(BuildContext context, BookingState b) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text(l10n.giftWrapQuestion, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        ...[ {'label': l10n.yesWrapIt, 'val': true},
          {'label': l10n.noGiftWrap, 'val': false}].map((opt) =>
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.personalMessage, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(l10n.addHeartfeltNote,
            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: b.personalMessage,
          maxLines: 6,
          maxLength: 200,
          style: const TextStyle(fontSize: 15, height: 1.5),
          decoration: InputDecoration(
            hintText: l10n.writeYourMessage,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
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
    final l10n = AppLocalizations.of(context);
    final slots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
        const SizedBox(height: 24),
        Text(l10n.availableTimeSlots, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: slots.map((slot) => GestureDetector(
            onTap: () => ref.read(bookingProvider.notifier).setTimeSlot(slot),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: b.timeSlot == slot ? AppColors.gold : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(
                slot,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: b.timeSlot == slot
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildStep4(BuildContext context, BookingState b) {
    final l10n = AppLocalizations.of(context);
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
        Text(l10n.bookingConfirmed, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(l10n.orderPlaced,
            style: TextStyle(fontSize: 14, color: AppColors.warmGray)),
        const SizedBox(height: 28),

        // Product summary card
        if (p != null)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
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
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.orderDetails, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _detailRow(Icons.card_giftcard, l10n.giftWrapLabel, b.giftWrap ? l10n.yes : l10n.no),
            if (b.personalMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              _detailRow(Icons.edit_note, l10n.messageLabel, b.personalMessage),
            ],
            Divider(height: 28, color: Theme.of(context).dividerColor),
            Text(l10n.delivery, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (b.deliveryDate != null) _detailRow(
              Icons.calendar_today, l10n.dateLabel,
              '${b.deliveryDate!.day}/${b.deliveryDate!.month}/${b.deliveryDate!.year}',
            ),
            if (b.timeSlot.isNotEmpty) ...[
              const SizedBox(height: 16),
              _detailRow(Icons.schedule, l10n.timeLabel, b.timeSlot),
            ],
          ]),
        ),

        const SizedBox(height: 24),
        _confirmRow(context, l10n.itemLabel, b.product?.name ?? ''),
        _confirmRow(context, l10n.giftWrapLabel, b.giftWrap ? l10n.yes : l10n.no),
        if (b.personalMessage.isNotEmpty) _confirmRow(context, l10n.messageLabel, b.personalMessage),
        if (b.deliveryDate != null) _confirmRow(context, l10n.deliveryDate, '${b.deliveryDate!.day}/${b.deliveryDate!.month}/${b.deliveryDate!.year}'),
        if (b.timeSlot.isNotEmpty) _confirmRow(context, l10n.timeLabel, b.timeSlot),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(bookingProvider.notifier).reset();
            context.go('/');
          },
          icon: const Icon(Icons.home_outlined, size: 20),
          label: Text(l10n.backToHome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
      Icon(icon, size: 18, color: AppColors.gold),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.warmGray)),
        ]),
      ),
    ],
  );

  Widget _confirmRow(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.darkSurface : AppColors.lightGray;
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
                  color: active ? AppColors.gold : inactiveColor,
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
                    color: isActive ? AppColors.gold : inactiveColor,
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
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.warmGray,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).cardTheme.color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withOpacity(isDark ? 0.15 : 0.06) : surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.gold : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.gold.withOpacity(isDark ? 0.25 : 0.12)
                  : (isDark ? AppColors.darkSurface : AppColors.lightGray.withOpacity(0.5)),
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
                color: Theme.of(context).colorScheme.onSurface,
              )),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.cream.withOpacity(0.7) : AppColors.warmGray,
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
