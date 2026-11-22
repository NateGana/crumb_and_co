import 'package:flutter/material.dart';

import '../config/brand.dart';
import '../models/bakery_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

// Customer order history with the live status set by the bakery.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  String _hint(Order o) => switch (o.status) {
    OrderStatus.pending => 'Waiting for the bakery to confirm your order.',
    OrderStatus.confirmed => 'Your order is confirmed.',
    OrderStatus.preparing => 'Your treats are being baked.',
    OrderStatus.readyForPickup => 'Ready! Come pick up your order.',
    OrderStatus.outForDelivery => 'On the way to you.',
    OrderStatus.completed => 'Enjoy your treats!',
    OrderStatus.cancelled => 'This order was cancelled.',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final orders = appState.myOrders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Bakery Orders', style: serif(context, 26)),
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: colors.gold),
                        const SizedBox(height: 12),
                        Text('No orders yet', style: serif(context, 22)),
                        const SizedBox(height: 6),
                        Text('Your orders will show up here.', style: TextStyle(color: colors.oat)),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final o = orders[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.espressoDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text('Order ${o.id}',
                                    style: TextStyle(color: colors.latte, fontWeight: FontWeight.w700)),
                              ),
                              StatusChip(o.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(_hint(o), style: TextStyle(color: colors.oat, fontSize: 12)),
                          const SizedBox(height: 10),
                          for (final item in o.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '${item.quantity}× ${item.product.name} (${item.variation.label})',
                                style: TextStyle(color: colors.latte, fontSize: 13),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            '${o.isDelivery ? 'Delivery' : 'Pickup'} · ${o.schedule}',
                            style: TextStyle(color: colors.oat, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Total ${peso(o.total)}',
                                    style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700)),
                              ),
                              if (o.status == OrderStatus.pending)
                                TextButton(
                                  onPressed: () async {
                                    final ok = await confirmDialog(
                                      context,
                                      'Cancel order ${o.id}?',
                                      'This puts the items back in stock.',
                                    );
                                    if (ok) appState.updateStatus(o, OrderStatus.cancelled);
                                  },
                                  child: const Text('Cancel order', style: TextStyle(color: Color(0xFFE57373))),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Future<bool> confirmDialog(BuildContext context, String title, String message) async {
  final colors = AppColors.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.espressoDark,
      title: Text(title, style: serif(ctx, 20)),
      content: Text(message, style: TextStyle(color: colors.oat)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Keep', style: TextStyle(color: colors.oat)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Confirm', style: TextStyle(color: colors.gold)),
        ),
      ],
    ),
  );
  return result ?? false;
}
