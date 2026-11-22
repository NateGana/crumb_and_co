import 'package:flutter/material.dart';

import '../../config/brand.dart';
import '../../models/bakery_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'product_form_page.dart';

// Business owner area: dashboard, orders, products, customers and settings.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final titles = ['Dashboard', 'Orders', 'Products', 'Customers', 'Settings'];

    return Scaffold(
      backgroundColor: colors.espresso,
      appBar: AppBar(
        backgroundColor: colors.espresso,
        iconTheme: IconThemeData(color: colors.gold),
        title: Text('${Brand.name} · ${titles[_tab]}', style: serif(context, 18), overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Back to shop',
            icon: Icon(Icons.storefront_outlined, color: colors.gold),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      floatingActionButton: _tab == 2
          ? FloatingActionButton(
              backgroundColor: colors.cinnamon,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductFormPage()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) => switch (_tab) {
              0 => const _Dashboard(),
              1 => const _AdminOrders(),
              2 => const _AdminProducts(),
              3 => const _Customers(),
              _ => const _Settings(),
            },
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colors.espressoDark,
        indicatorColor: colors.cinnamon.withValues(alpha: 0.25),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          for (final (icon, label) in [
            (Icons.insights_outlined, 'Dashboard'),
            (Icons.receipt_long_outlined, 'Orders'),
            (Icons.cookie_outlined, 'Products'),
            (Icons.people_outline, 'Customers'),
            (Icons.settings_outlined, 'Settings'),
          ])
            NavigationDestination(icon: Icon(icon, color: colors.oat), label: label),
        ],
      ),
    );
  }
}

// ---------------- Dashboard ----------------
class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final stats = [
      ('Total Sales', peso(appState.totalSales), Icons.payments_outlined),
      ('Total Orders', '${appState.totalOrders}', Icons.receipt_long_outlined),
      ('Pending Orders', '${appState.countByStatus(OrderStatus.pending)}', Icons.hourglass_bottom),
      ('Completed Orders', '${appState.countByStatus(OrderStatus.completed)}', Icons.check_circle_outline),
      ('Total Products', '${appState.products.length}', Icons.cookie_outlined),
      ('Low / Out of Stock', '${appState.lowStockCount}', Icons.warning_amber_rounded),
    ];

    Widget listCard(String title, List<MapEntry<String, int>> rows, {String empty = 'No sales yet'}) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.espressoDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: serif(context, 17)),
            const SizedBox(height: 8),
            if (rows.isEmpty) Text(empty, style: TextStyle(color: colors.oat, fontSize: 13)),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(r.key, style: TextStyle(color: colors.latte, fontSize: 13))),
                    Text('${r.value} sold', style: TextStyle(color: colors.gold, fontSize: 13)),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    final low = appState.products
        .where((p) => appState.stockLevel(p) != StockLevel.inStock)
        .map((p) => MapEntry(p.name, p.stock))
        .toList();
    final byCategory = appState.salesByCategory();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final w = (box.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final s in stats)
                  Container(
                    width: w,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.espressoDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(s.$3, color: colors.gold, size: 22),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(s.$2, style: serif(context, 24)),
                        ),
                        Text(s.$1, style: TextStyle(color: colors.oat, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        listCard('Bestselling Cookies', appState.bestSelling('Cookies')),
        listCard('Bestselling Brownies', appState.bestSelling('Brownies')),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.espressoDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sales by Category', style: serif(context, 17)),
              const SizedBox(height: 8),
              if (byCategory.isEmpty) Text('No sales yet', style: TextStyle(color: colors.oat, fontSize: 13)),
              for (final e in byCategory.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key, style: TextStyle(color: colors.latte, fontSize: 13))),
                      Text(peso(e.value), style: TextStyle(color: colors.gold, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.espressoDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Low Stock Products', style: serif(context, 17)),
              const SizedBox(height: 8),
              if (low.isEmpty) Text('Everything is well stocked.', style: TextStyle(color: colors.oat)),
              for (final r in low)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(r.key, style: TextStyle(color: colors.latte, fontSize: 13))),
                      Text('${r.value} left', style: TextStyle(color: colors.gold, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- Orders ----------------
class _AdminOrders extends StatelessWidget {
  const _AdminOrders();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final orders = appState.orders;
    if (orders.isEmpty) {
      return Center(child: Text('No orders yet.', style: TextStyle(color: colors.oat)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
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
                    child: Text('${o.id} · ${o.customerName}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.latte, fontWeight: FontWeight.w700)),
                  ),
                  StatusChip(o.status),
                ],
              ),
              const SizedBox(height: 6),
              for (final item in o.items)
                Text('${item.quantity}× ${item.product.name} (${item.variation.label})',
                    style: TextStyle(color: colors.latte, fontSize: 13)),
              const SizedBox(height: 6),
              Text('${o.isDelivery ? 'Delivery: ${o.address}' : 'Pickup'} · ${o.schedule}',
                  style: TextStyle(color: colors.oat, fontSize: 12)),
              Text('${o.contact} · ${o.payment}', style: TextStyle(color: colors.oat, fontSize: 12)),
              if (o.notes.isNotEmpty)
                Text('Notes: ${o.notes}', style: TextStyle(color: colors.oat, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(peso(o.total),
                        style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700)),
                  ),
                  if (o.status != OrderStatus.cancelled)
                    PopupMenuButton<OrderStatus>(
                      color: colors.espressoDark,
                      onSelected: (s) => appState.updateStatus(o, s),
                      itemBuilder: (_) => [
                        for (final s in OrderStatus.values)
                          PopupMenuItem(value: s, child: Text(s.label, style: TextStyle(color: colors.latte))),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.cinnamon),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Update status', style: TextStyle(color: colors.cinnamon, fontSize: 13)),
                            Icon(Icons.arrow_drop_down, color: colors.cinnamon),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------- Products & inventory ----------------
class _AdminProducts extends StatelessWidget {
  const _AdminProducts();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final products = appState.products;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final p = products[i];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.espressoDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 60, height: 60, child: ProductImage(p.image)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductFormPage(product: p)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.latte, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(peso(p.startingPrice), style: TextStyle(color: colors.gold, fontSize: 12)),
                          StockBadge(appState.stockLevel(p)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stockBtn(colors, Icons.remove, () => appState.changeStock(p, -1)),
                      SizedBox(
                        width: 34,
                        child: Text('${p.stock}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.latte, fontWeight: FontWeight.w600)),
                      ),
                      _stockBtn(colors, Icons.add, () => appState.changeStock(p, 1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Available', style: TextStyle(color: colors.oat, fontSize: 10)),
                      Switch(
                        value: p.available,
                        activeThumbColor: colors.cinnamon,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (v) {
                          p.available = v;
                          appState.touch();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stockBtn(AppColors colors, IconData icon, VoidCallback tap) => InkWell(
    onTap: tap,
    customBorder: const CircleBorder(),
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colors.line)),
      child: Icon(icon, size: 16, color: colors.gold),
    ),
  );
}

// ---------------- Customers ----------------
class _Customers extends StatelessWidget {
  const _Customers();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final list = appState.customers;
    if (list.isEmpty) {
      return Center(child: Text('No customers yet.', style: TextStyle(color: colors.oat)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final c = list[i];
        return Container(
          decoration: BoxDecoration(
            color: colors.espressoDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line),
          ),
          child: ListTile(
            leading: Icon(Icons.person_outline, color: colors.gold),
            title: Text(c.name, style: TextStyle(color: colors.latte, fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${c.email}${c.contact.isEmpty ? '' : ' · ${c.contact}'}',
              style: TextStyle(color: colors.oat, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${c.orders} orders', style: TextStyle(color: colors.oat, fontSize: 12)),
                Text(peso(c.spent), style: TextStyle(color: colors.gold, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------- Settings ----------------
class _Settings extends StatefulWidget {
  const _Settings();

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  final _fee = TextEditingController(text: appState.deliveryFee.round().toString());
  final _low = TextEditingController(text: appState.lowStockLimit.toString());
  final _phone = TextEditingController(text: appState.businessPhone);

  @override
  void dispose() {
    _fee.dispose();
    _low.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.oat),
      filled: true,
      fillColor: colors.espressoDark,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.gold),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Business settings', style: serif(context, 20)),
        const SizedBox(height: 12),
        TextField(
          controller: _fee,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colors.latte),
          decoration: deco('Delivery fee (₱)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _low,
          keyboardType: TextInputType.number,
          style: TextStyle(color: colors.latte),
          decoration: deco('Low stock warning at (pieces)'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: colors.latte),
          decoration: deco('Business contact number'),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Save settings',
          onPressed: () {
            appState.deliveryFee = double.tryParse(_fee.text) ?? appState.deliveryFee;
            appState.lowStockLimit = int.tryParse(_low.text) ?? appState.lowStockLimit;
            appState.businessPhone = _phone.text.trim();
            appState.touch();
            showSnack(context, 'Settings saved.');
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Promotions: open a product and set a discount percentage to put it in Special Offers.',
          style: TextStyle(color: colors.oat, fontSize: 12),
        ),
      ],
    );
  }
}
