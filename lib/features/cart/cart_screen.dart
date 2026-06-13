import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cart_item.dart';
import '../../state/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Map<String, Timer> _timers = {};
  final Map<String, int> _remainingSeconds = {};

  @override
  void dispose() {
    for (final t in _timers.values) t.cancel();
    super.dispose();
  }

  void _startCountdown(CartItem item) {
    if (_timers.containsKey(item.id)) return;
    final elapsed = DateTime.now().difference(item.createdAt).inSeconds;
    final remaining = 300 - elapsed;
    if (remaining <= 0) return;

    _remainingSeconds[item.id] = remaining;
    _timers[item.id] = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = _remainingSeconds[item.id]! - 1;
      if (newRemaining <= 0) {
        timer.cancel();
        _timers.remove(item.id);
        _remainingSeconds.remove(item.id);
        if (mounted) setState(() {});
      } else {
        setState(() => _remainingSeconds[item.id] = newRemaining);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Book a product to see it here',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final item = items[i];
                if (item.status == CartItemStatus.pending) _startCountdown(item);
                return _CartItemCard(item: item, remaining: _remainingSeconds[item.id]);
              },
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final int? remaining;
  const _CartItemCard({required this.item, this.remaining});

  @override
  Widget build(BuildContext context) {
    final isPending = item.status == CartItemStatus.pending;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.warning.withOpacity(0.3) : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(item.product.images.first,
                  width: 64, height: 64, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.product.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gold)),
              ]),
            ),
            _StatusBadge(item: item, remaining: remaining),
          ]),
        ),
        if (isPending || item.deliveryDate != null || item.personalMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(children: [
              if (item.deliveryDate != null || item.timeSlot.isNotEmpty)
                Row(children: [
                  Icon(Icons.calendar_today, size: 14, color: AppColors.warmGray),
                  const SizedBox(width: 6),
                  Text(
                    item.deliveryDate != null
                        ? '${item.deliveryDate!.day}/${item.deliveryDate!.month}/${item.deliveryDate!.year}'
                        : '',
                    style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                  ),
                  if (item.timeSlot.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.schedule, size: 14, color: AppColors.warmGray),
                    const SizedBox(width: 6),
                    Text(item.timeSlot,
                        style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
                  ],
                  const Spacer(),
                  if (item.giftWrap)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.card_giftcard, size: 14, color: AppColors.goldLight),
                      const SizedBox(width: 4),
                      Text('Gift Wrap',
                          style: TextStyle(fontSize: 11, color: AppColors.goldLight)),
                    ]),
                ]),
              if (item.personalMessage.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.edit_note, size: 14, color: AppColors.warmGray),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item.personalMessage,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.warmGray, fontStyle: FontStyle.italic)),
                  ),
                ]),
              ],
              if (isPending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text(
                      remaining != null
                          ? 'Awaiting artisan confirmation... ${_formatTime(remaining!)}'
                          : 'Awaiting artisan confirmation...',
                      style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w500),
                    ),
                  ]),
                ),
            ]),
          ),
      ]),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final CartItem item;
  final int? remaining;
  const _StatusBadge({required this.item, this.remaining});

  @override
  Widget build(BuildContext context) {
    final isPending = item.status == CartItemStatus.pending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPending
            ? AppColors.warning.withOpacity(0.12)
            : AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          isPending ? Icons.hourglass_empty : Icons.check_circle,
          size: 14,
          color: isPending ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(width: 4),
        Text(
          isPending ? 'Pending' : 'Confirmed',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isPending ? AppColors.warning : AppColors.success,
          ),
        ),
      ]),
    );
  }
}
