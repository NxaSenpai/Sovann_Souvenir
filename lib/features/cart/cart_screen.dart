import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_repository.dart';
import '../../models/product.dart';
import '../../state/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/empty_state.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});
  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  void _goToCheckout() {
    if (ref.read(cartProvider).isEmpty) return;
    HapticFeedback.mediumImpact();
    context.push('/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cart  = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final repo   = MockRepository.instance;

    final items = cart.entries.map((e) {
      final product = repo.products.firstWhere((p) => p.id == e.key);
      return _CartEntry(product: product, quantity: e.value);
    }).toList();

    final totalPrice = items.fold(
        0.0, (sum, item) => sum + item.product.price * item.quantity);
    final totalItems = items.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: _buildAppBar(context, isDark, items.length),
      body: items.isEmpty
          ? EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: l10n.cartEmpty,
        subtitle: l10n.cartEmptySubtitle,
      )
          : Column(children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: items.length + 1, // +1 for order summary card
            itemBuilder: (context, i) {
              if (i < items.length) {
                final entry = items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartItemTile(
                    key: ValueKey(entry.product.id),
                    entry: entry,
                    isDark: isDark,
                    onIncrement: () {
                      HapticFeedback.selectionClick();
                      ref.read(cartProvider.notifier).add(entry.product.id);
                    },
                    onDecrement: () {
                      HapticFeedback.selectionClick();
                      ref.read(cartProvider.notifier).remove(entry.product.id);
                    },
                    onDelete: () {
                      HapticFeedback.mediumImpact();
                      ref.read(cartProvider.notifier).deleteItem(entry.product.id);
                    },
                  ),
                );
              }
              // Order summary card
              return _OrderSummaryCard(
                itemCount: totalItems,
                subtotal: totalPrice,
                isDark: isDark,
              );
            },
          ),
        ),

        // ── Bottom checkout bar ──────────────────────────────────────
        _CheckoutBar(
          totalPrice: totalPrice,
          itemCount: totalItems,
          isDark: isDark,
          onPurchase: _goToCheckout,
        ),
      ]),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isDark, int uniqueItems) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.cream : AppColors.charcoal),
        onPressed: () => context.pop(),
      ),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.myCart,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: isDark ? AppColors.cream : AppColors.charcoal,
            )),
        if (uniqueItems > 0)
          Text(
            '$uniqueItems ${uniqueItems == 1 ? 'item type' : 'item types'}',
            style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
          ),
      ]),
      actions: [
        if (uniqueItems > 0)
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(cartProvider.notifier).clearAll();
            },
            child: Text(l10n.clearAll,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── Order summary card ────────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final int itemCount;
  final double subtotal;
  final bool isDark;
  const _OrderSummaryCard({
    required this.itemCount,
    required this.subtotal,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const shipping = 0.0; // free
    final total    = subtotal + shipping;

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withAlpha(isDark ? 35 : 25),
        ),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 3.5, height: 16,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2)),
          ),
          Text(l10n.orderSummary,
              style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 15,
                color: isDark ? AppColors.cream : AppColors.charcoal,
              )),
        ]),
        const SizedBox(height: 16),

        _SummaryRow(label: '${l10n.orderSummary} ($itemCount ${l10n.itemsCount(itemCount)})',
            value: '\$${subtotal.toStringAsFixed(2)}', isDark: isDark),
        const SizedBox(height: 10),
        _SummaryRow(label: l10n.delivery, value: l10n.freeDelivery, isDark: isDark,
            valueColor: AppColors.success),
        const SizedBox(height: 10),
        _SummaryRow(label: l10n.giftWrapLabel, value: l10n.giftWrapAddAtCheckout, isDark: isDark,
            valueColor: AppColors.warmGray),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Divider(
            color: isDark ? AppColors.darkSurface : AppColors.lightGray,
            height: 1, thickness: 1,
          ),
        ),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total',
              style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 16,
                color: isDark ? AppColors.cream : AppColors.charcoal,
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(70), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Text('\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16,
                )),
          ),
        ]),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 3,
        child: Text(label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
      ),
      const SizedBox(width: 12),
      Flexible(
        flex: 2,
        child: Text(value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? AppColors.cream : AppColors.charcoal),
            )),
      ),
    ]);
  }
}

// ── Cart item tile ────────────────────────────────────────────────────────────
class _CartEntry {
  final Product product;
  final int quantity;
  const _CartEntry({required this.product, required this.quantity});
}

class _CartItemTile extends StatelessWidget {
  final _CartEntry entry;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const _CartItemTile({
    super.key,
    required this.entry,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p   = entry.product;
    final qty = entry.quantity;
    final lineTotal = p.price * qty;

    return Dismissible(
      key: ValueKey('dismiss-${p.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
            const SizedBox(height: 4),
            Text(l10n.removeItem, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => context.push('/product/${p.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.gold.withAlpha(isDark ? 30 : 20),
            ),
            boxShadow: isDark
                ? null
                : [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(children: [

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: p.images.first,
                width: 76, height: 76, fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 76, height: 76,
                  color: isDark ? AppColors.darkSurface : AppColors.lightGray,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Name + price
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14,
                      color: isDark ? AppColors.cream : AppColors.charcoal,
                      height: 1.3,
                    )),
                const SizedBox(height: 6),
                Row(children: [
                  Text('\$${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.warmGray, fontSize: 12,
                        decoration: TextDecoration.none,
                      )),
                  if (qty > 1) ...[
                    const Text('  ×  ',
                        style: TextStyle(color: AppColors.warmGray, fontSize: 12)),
                    Text('$qty',
                        style: const TextStyle(color: AppColors.warmGray, fontSize: 12)),
                    const Text('  =  ',
                        style: TextStyle(color: AppColors.warmGray, fontSize: 12)),
                    Text('\$${lineTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800, fontSize: 13,
                        )),
                  ],
                ]),
              ]),
            ),

            const SizedBox(width: 10),

            // Quantity stepper + delete
            Column(children: [
              // Vertical stepper
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightGray.withAlpha(180),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withAlpha(isDark ? 40 : 30)),
                ),
                child: Column(children: [
                  _StepButton(icon: Icons.add_rounded, onTap: onIncrement, isDark: isDark),
                  Container(
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                    ),
                    child: Center(
                      child: Text('$qty',
                          style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15,
                            color: isDark ? AppColors.cream : AppColors.charcoal,
                          )),
                    ),
                  ),
                  _StepButton(icon: Icons.remove_rounded, onTap: onDecrement, isDark: isDark),
                ]),
              ),
              const SizedBox(height: 8),
              // Delete button
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(isDark ? 40 : 18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withAlpha(60)),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 17),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _StepButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36, height: 34,
        child: Icon(icon, size: 16,
            color: isDark ? AppColors.cream : AppColors.charcoal),
      ),
    );
  }
}

// ── Checkout bar ──────────────────────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  final double totalPrice;
  final int itemCount;
  final bool isDark;
  final VoidCallback onPurchase;

  const _CheckoutBar({
    required this.totalPrice,
    required this.itemCount,
    required this.isDark,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPad),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withAlpha(30) : AppColors.lightGray,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 70 : 18),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(children: [
        // Total
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
          const SizedBox(height: 2),
          Text('\$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900,
                color: isDark ? AppColors.cream : AppColors.charcoal,
                letterSpacing: -0.5,
              )),
        ]),

        const SizedBox(width: 16),

        // Purchase button
        Expanded(
          child: SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, Color(0xFFB5840A), AppColors.goldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(100),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.shopping_bag_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.proceedToCheckout,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}