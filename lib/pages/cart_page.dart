import 'package:flutter/material.dart';

import '../config/brand.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cart = appState.cart;

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag_outlined, size: 56, color: colors.gold),
              const SizedBox(height: 12),
              Text('Your cart is empty', style: serif(context, 22)),
              const SizedBox(height: 6),
              Text('Add some cookies or brownies to get started.',
                  textAlign: TextAlign.center, style: TextStyle(color: colors.oat)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => appState.homeTab.value = 1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.cinnamon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Browse the menu'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Your Cart', style: serif(context, 26)),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            itemCount: cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final item = cart[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.espressoDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(width: 72, height: 72, child: ProductImage(item.product.image)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: colors.latte, fontWeight: FontWeight.w600)),
                              ),
                              InkWell(
                                onTap: () => appState.removeFromCart(item),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.delete_outline, size: 20, color: colors.oat),
                                ),
                              ),
                            ],
                          ),
                          Text(item.variation.label, style: TextStyle(color: colors.oat, fontSize: 12)),
                          if (item.addOns.isNotEmpty)
                            Text('+ ${item.addOns.map((a) => a.label).join(', ')}',
                                style: TextStyle(color: colors.oat, fontSize: 12)),
                          if (item.notes.isNotEmpty)
                            Text('Note: ${item.notes}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: colors.oat, fontSize: 12, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 6,
                            spacing: 8,
                            children: [
                              QuantityStepper(
                                value: item.quantity,
                                onChanged: (q) {
                                  final error = appState.setQuantity(item, q);
                                  if (error != null) showSnack(context, error);
                                },
                              ),
                              Text(peso(item.subtotal),
                                  style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: colors.espressoDark,
            border: Border(top: BorderSide(color: colors.line)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: TextStyle(color: colors.oat)),
                  Text(peso(appState.cartSubtotal),
                      style: TextStyle(color: colors.latte, fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Checkout',
                icon: Icons.lock_outline,
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
