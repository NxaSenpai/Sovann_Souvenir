import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/mock_repository.dart';
import '../../state/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/generated/app_localizations.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _giftWrap = false;
  final _messageCtrl = TextEditingController();
  DateTime? _deliveryDate;
  bool _isPlacing = false;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _isPlacing = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final repo = MockRepository.instance;

      // Calculate total
      double total = 0;
      final items = <Map<String, dynamic>>[];
      for (final entry in cart.entries) {
        final product = repo.products.firstWhere((p) => p.id == entry.key);
        final lineTotal = product.price * entry.value;
        total += lineTotal;
        items.add({
          'product_id': product.id,
          'quantity': entry.value,
          'price_at_time': product.price,
          // store in local var for display — not inserted
          '_name': product.name,
          '_image': product.images.first,
        });
      }

      // Create the order
      final orderRes = await Supabase.instance.client.from('orders').insert({
        'user_id': userId,
        'status': 'pending',
        'total': total,
        'gift_wrap': _giftWrap,
        'personal_message': _messageCtrl.text.trim(),
        'delivery_date': _deliveryDate?.toIso8601String().substring(0, 10),
        'time_slot': '',
      }).select('id');

      final orderId = (orderRes as List).first['id'] as String;

      // Insert only valid columns (order_items table: id, order_id, product_id, quantity, price_at_time)
      for (final item in items) {
        await Supabase.instance.client.from('order_items').insert({
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price_at_time': item['price_at_time'],
        });
      }

      ref.read(cartProvider.notifier).clearAll();

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.orderPlacedSuccess),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo = MockRepository.instance;

    final items = cart.entries.map((e) {
      final p = repo.products.firstWhere((p) => p.id == e.key);
      return (product: p, quantity: e.value);
    }).toList();

    final total = items.fold(0.0, (s, i) => s + i.product.price * i.quantity);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
        elevation: 0,
        title: Text(l10n.checkout, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Order items ──
          Text(l10n.orderSummary,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.cream : AppColors.charcoal)),
          const SizedBox(height: 12),
          ...items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                        imageUrl: item.product.images.first,
                        width: 52, height: 52, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: TextStyle(fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? AppColors.cream : AppColors.charcoal),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('Qty: ${item.quantity}  •  \$${item.product.price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
                        ]),
                  ),
                  Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15,
                          color: isDark ? AppColors.cream : AppColors.charcoal)),
                ]),
              )),

          const SizedBox(height: 20),

          // ── Delivery date ──
          Text(l10n.delivery,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.cream : AppColors.charcoal)),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.gold),
                const SizedBox(width: 12),
                Text(
                  _deliveryDate != null
                      ? '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}'
                      : l10n.chooseDeliveryDateOptional,
                  style: TextStyle(
                      color: _deliveryDate != null
                          ? (isDark ? AppColors.cream : AppColors.charcoal)
                          : AppColors.warmGray),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // ── Gift wrap ──
          Text(l10n.extras,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.cream : AppColors.charcoal)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.card_giftcard, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.giftWrapQuestion,
                    style: TextStyle(fontSize: 14,
                        color: isDark ? AppColors.cream : AppColors.charcoal)),
              ),
              Switch(
                value: _giftWrap,
                onChanged: (v) => setState(() => _giftWrap = v),
                activeColor: AppColors.gold,
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Personal message ──
          TextField(
            controller: _messageCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.writeYourMessage,
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),

          const SizedBox(height: 32),

          // ── Total + Place Order ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Total', style: TextStyle(fontSize: 16,
                    color: isDark ? AppColors.cream : AppColors.charcoal)),
                Text('\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                        color: AppColors.gold)),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isPlacing ? null : _placeOrder,
                  icon: _isPlacing
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_outline),
                  label: Text(_isPlacing ? l10n.placingOrder : l10n.placeOrder,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ]),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
        ],
      ),
    );
  }
}
