import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/mock_repository.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../l10n/generated/app_localizations.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<CustomerOrder>> _ordersFuture;
  late TabController _tabController;
  late List<String> _tabs;

  List<String> _buildTabs() {
    final l10n = AppLocalizations.of(context);
    return [l10n.allOrders, l10n.activeOrders, l10n.deliveredOrders, l10n.cancelledOrders];
  }

  @override
  void initState() {
    super.initState();
    _tabs = ['All', 'Active', 'Delivered', 'Cancelled']; // placeholder
    _tabController = TabController(length: 4, vsync: this);
    _ordersFuture = _fetchOrders();
  }

  void _refreshOrders() {
    setState(() => _ordersFuture = _fetchOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<CustomerOrder>> _fetchOrders() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final repo = MockRepository.instance;
      final orders = (data as List).map((j) {
        // Enrich order_items with product name/image from mock data
        final items = (j['order_items'] as List<dynamic>?)?.map((item) {
          final productId = item['product_id'] as String;
          final product = repo.products.firstWhere(
            (p) => p.id == productId,
            orElse: () => repo.products.first,
          );
          return {
            ...item as Map<String, dynamic>,
            'product_name': product.name,
            'product_image': product.images.first,
          };
        }).toList();
        return CustomerOrder.fromJson({
          ...j as Map<String, dynamic>,
          'order_items': items,
        });
      }).toList();
      return orders;
    } catch (_) {
      return [];
    }
  }

  List<CustomerOrder> _filter(List<CustomerOrder> orders, int tabIndex) {
    switch (tabIndex) {
      case 1: // Active
        return orders.where((o) =>
            ['pending', 'confirmed', 'processing', 'shipped']
                .contains(o.status)).toList();
      case 2: // Delivered
        return orders.where((o) => o.status == 'delivered').toList();
      case 3: // Cancelled
        return orders.where((o) => o.status == 'cancelled').toList();
      default:
        return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _tabs = _buildTabs();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: _buildAppBar(isDark),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async => _refreshOrders(),
        child: FutureBuilder<List<CustomerOrder>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
                          SizedBox(height: 16),
                          Text('Fetching your orders…',
                              style: TextStyle(color: AppColors.warmGray, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final allOrders = snapshot.data ?? [];

            if (allOrders.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3,
                    child: const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      subtitle: 'Your handcrafted gifts will appear here once ordered',
                    ),
                  ),
                ],
              );
            }

            return TabBarView(
              controller: _tabController,
              children: _tabs.asMap().entries.map((entry) {
                final filtered = _filter(allOrders, entry.key);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: _tabEmptyIcon(entry.key),
                    title: _tabEmptyTitle(entry.key),
                    subtitle: '',
                  );
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      _OrderCard(order: filtered[i], isDark: isDark),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.cream : AppColors.charcoal),
        onPressed: () => context.go('/'),
      ),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.myOrders,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: isDark ? AppColors.cream : AppColors.charcoal,
            )),
        Text(l10n.trackYourGifts,
            style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
      ]),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightGray.withAlpha(200),
            borderRadius: BorderRadius.circular(50),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withAlpha(80),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.warmGray,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
    );
  }

  IconData _tabEmptyIcon(int i) {
    switch (i) {
      case 1: return Icons.local_shipping_outlined;
      case 2: return Icons.check_circle_outline;
      case 3: return Icons.cancel_outlined;
      default: return Icons.receipt_long_outlined;
    }
  }

  String _tabEmptyTitle(int i) {
    final l10n = AppLocalizations.of(context);
    switch (i) {
      case 1: return l10n.noActiveOrders;
      case 2: return l10n.noDeliveredOrders;
      case 3: return l10n.noCancelledOrders;
      default: return l10n.noOrdersYet;
    }
  }
}

// ── Order card ───────────────────────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final CustomerOrder order;
  final bool isDark;
  const _OrderCard({required this.order, required this.isDark});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o        = widget.order;
    final isDark   = widget.isDark;
    final statusClr = _statusColor(o.status);
    final isCancelled = o.status == 'cancelled';

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withAlpha(isDark ? 30 : 22),
          ),
          boxShadow: isDark
              ? null
              : [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Card header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [

              // Status icon circle
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: statusClr.withAlpha(isDark ? 45 : 22),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusClr.withAlpha(80), width: 1.5),
                ),
                child: Icon(_statusIcon(o.status), color: statusClr, size: 20),
              ),

              const SizedBox(width: 12),

              // Order ID + date
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  '${l10n.orderNumber}${o.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isDark ? AppColors.cream : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(o.createdAt),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.warmGray),
                ),
              ])),

              // Total + status pill
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  '\$${o.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? AppColors.cream : AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusClr.withAlpha(isDark ? 45 : 22),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: statusClr.withAlpha(80)),
                  ),
                  child: Text(
                    o.statusLabel,
                    style: TextStyle(color: statusClr, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ]),
            ]),
          ),

          // ── Progress stepper (non-cancelled only) ────────────────────────
          if (!isCancelled) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StatusStepper(currentStatus: o.status, isDark: isDark),
            ),
            const SizedBox(height: 12),
          ],

          // ── Divider ──────────────────────────────────────────────────────
          Divider(
            color: isDark ? AppColors.darkSurface : AppColors.lightGray,
            height: 1, thickness: 1,
            indent: 16, endIndent: 16,
          ),

          // ── Collapsed summary row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(children: [
              if (o.giftWrap) ...[
                const Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(l10n.giftWrapIncluded,
                    style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
              ],
              if (o.deliveryDate != null) ...[
                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.warmGray),
                const SizedBox(width: 4),
                Text(
                  '${o.deliveryDate}${o.timeSlot != null ? '  ${o.timeSlot}' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
                ),
              ],
              const Spacer(),
              Icon(
                _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppColors.warmGray, size: 20,
              ),
            ]),
          ),

          // ── Expanded details ─────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 260),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Divider(
                  color: isDark ? AppColors.darkSurface : AppColors.lightGray,
                  height: 1, thickness: 1,
                ),
                const SizedBox(height: 14),

                // Detail rows
                _DetailRow(label: l10n.orderId,      value: o.id,              isDark: isDark),
                _DetailRow(label: l10n.status,       value: o.statusLabel,     isDark: isDark, valueColor: statusClr),
                _DetailRow(label: l10n.total,        value: '\$${o.total.toStringAsFixed(2)}', isDark: isDark),
                _DetailRow(label: l10n.giftWrapLabel, value: o.giftWrap ? l10n.yes : l10n.no, isDark: isDark),
                if (o.deliveryDate != null)
                  _DetailRow(label: l10n.delivery,   value: o.deliveryDate!,   isDark: isDark),
                if (o.timeSlot != null && o.timeSlot!.isNotEmpty)
                  _DetailRow(label: l10n.timeLabel,  value: o.timeSlot!,       isDark: isDark),
                if (o.personalMessage != null && o.personalMessage!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Gold open-quote
                    Text('\u201C',
                        style: TextStyle(
                          fontSize: 30, height: 0.9,
                          color: AppColors.gold.withAlpha(160),
                          fontWeight: FontWeight.w900,
                        )),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(o.personalMessage!,
                          style: TextStyle(
                            fontSize: 13, fontStyle: FontStyle.italic, height: 1.5,
                            color: isDark ? AppColors.cream.withAlpha(180) : AppColors.warmGray,
                          )),
                    ),
                  ]),
                ],

                // ── Order items ──
                if (o.items.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(l10n.items,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.cream : AppColors.charcoal)),
                  const SizedBox(height: 8),
                  ...o.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.gold.withAlpha(isDark ? 40 : 22),
                        ),
                        child: item.productImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(item.productImage!, width: 40, height: 40, fit: BoxFit.cover),
                              )
                            : Icon(Icons.card_giftcard, size: 18, color: AppColors.gold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.productName ?? 'Product',
                          style: TextStyle(fontSize: 13, color: isDark ? AppColors.cream : AppColors.charcoal),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('x${item.quantity}',
                          style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
                      const SizedBox(width: 12),
                      Text('\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.cream : AppColors.charcoal)),
                    ]),
                  )),
                  Divider(
                    color: isDark ? AppColors.darkSurface : AppColors.lightGray,
                    height: 1, thickness: 1,
                  ),
                ],

                const SizedBox(height: 14),

                // Re-order button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(l10n.shopAgain,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'pending':    return Colors.orange;
      case 'confirmed':  return Colors.blue;
      case 'processing': return Colors.purple;
      case 'shipped':    return Colors.teal;
      case 'delivered':  return AppColors.success;
      case 'cancelled':  return AppColors.error;
      default:           return AppColors.warmGray;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':    return Icons.hourglass_top_rounded;
      case 'confirmed':  return Icons.check_circle_outline_rounded;
      case 'processing': return Icons.inventory_2_outlined;
      case 'shipped':    return Icons.local_shipping_outlined;
      case 'delivered':  return Icons.done_all_rounded;
      case 'cancelled':  return Icons.cancel_outlined;
      default:           return Icons.receipt_outlined;
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  •  '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Status stepper ────────────────────────────────────────────────────────────
class _StatusStepper extends StatelessWidget {
  final String currentStatus;
  final bool isDark;

  const _StatusStepper({required this.currentStatus, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      ('pending',    l10n.placed,      Icons.receipt_outlined),
      ('confirmed',  l10n.confirmed,   Icons.check_circle_outline_rounded),
      ('processing', l10n.packing,     Icons.inventory_2_outlined),
      ('shipped',    l10n.shipped_,    Icons.local_shipping_outlined),
      ('delivered',  l10n.delivered_,  Icons.done_all_rounded),
    ];
    final currentIdx = steps.indexWhere((s) => s.$1 == currentStatus);

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIdx = i ~/ 2;
          final isCompleted = stepIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? const LinearGradient(colors: [AppColors.gold, AppColors.goldLight])
                    : null,
                color: isCompleted ? null : (isDark ? AppColors.darkSurface : AppColors.lightGray),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }

        final stepIdx   = i ~/ 2;
        final step      = steps[stepIdx];
        final isDone    = stepIdx < currentIdx;
        final isCurrent = stepIdx == currentIdx;

        return Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppColors.gold
                  : isCurrent
                  ? Colors.transparent
                  : (isDark ? AppColors.darkSurface : AppColors.lightGray),
              border: isCurrent
                  ? const Border.fromBorderSide(
                  BorderSide(color: AppColors.gold, width: 2.5))
                  : null,
              boxShadow: (isDone || isCurrent)
                  ? [BoxShadow(color: AppColors.gold.withAlpha(80), blurRadius: 6)]
                  : null,
            ),
            child: Icon(
              step.$3,
              size: 14,
              color: isDone
                  ? Colors.white
                  : isCurrent
                  ? AppColors.gold
                  : AppColors.warmGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step.$2,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
              color: isCurrent
                  ? AppColors.gold
                  : isDone
                  ? (isDark ? AppColors.cream : AppColors.charcoal)
                  : AppColors.warmGray,
            ),
          ),
        ]);
      }),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.warmGray)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? (isDark ? AppColors.cream : AppColors.charcoal),
              )),
        ),
      ]),
    );
  }
}