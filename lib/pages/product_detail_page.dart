import 'package:flutter/material.dart';

import '../config/brand.dart';
import '../models/bakery_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Product? _product;
  late ProductVariation _variation;
  final Set<String> _addOns = {};
  final _notes = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_product == null) {
      _product = ModalRoute.of(context)!.settings.arguments as Product;
      _variation = _product!.variations.first;
    }
  }

  double get _unitPrice {
    final extras = _product!.addOns
        .where((a) => _addOns.contains(a.label))
        .fold(0.0, (s, a) => s + a.price);
    return _product!.priceOf(_variation) + extras;
  }

  void _addToCart() {
    final p = _product!;
    final error = appState.addToCart(
      CartItem(
        product: p,
        variation: _variation,
        addOns: p.addOns.where((a) => _addOns.contains(a.label)).toList(),
        quantity: _quantity,
        notes: _notes.text.trim(),
      ),
    );
    if (error != null) {
      showSnack(context, error);
      return;
    }
    showSnack(context, '${p.name} added to your cart.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final p = _product!;
    final level = appState.stockLevel(p);
    final canOrder = level != StockLevel.outOfStock;

    return Scaffold(
      backgroundColor: colors.espresso,
      appBar: AppBar(
        backgroundColor: colors.espresso,
        iconTheme: IconThemeData(color: colors.gold),
        title: Text(p.name, style: serif(context, 18), overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(aspectRatio: 1.4, child: ProductImage(p.image)),
                    ),
                    const SizedBox(height: 16),
                    Text(p.name, style: serif(context, 24)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StockBadge(level),
                        if (p.bestSeller) _tag(colors, 'Best Seller'),
                        if (p.isNew) _tag(colors, 'New'),
                        if (p.discountPercent > 0) _tag(colors, '${p.discountPercent.round()}% off'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(p.description, style: TextStyle(color: colors.oat, height: 1.4)),
                    if (p.allergens.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: colors.gold),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Allergens: ${p.allergens}',
                              style: TextStyle(color: colors.oat, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text('Choose a size', style: serif(context, 18)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final v in p.variations)
                          ChoiceChip(
                            label: Text('${v.label} · ${peso(p.priceOf(v))}'),
                            selected: v == _variation,
                            showCheckmark: false,
                            selectedColor: colors.cinnamon,
                            backgroundColor: colors.espressoDark,
                            side: BorderSide(color: colors.line),
                            labelStyle: TextStyle(
                              color: v == _variation ? Colors.white : colors.latte,
                              fontSize: 13,
                            ),
                            onSelected: (_) => setState(() => _variation = v),
                          ),
                      ],
                    ),
                    if (p.addOns.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Add-ons', style: serif(context, 18)),
                      for (final a in p.addOns)
                        CheckboxListTile(
                          value: _addOns.contains(a.label),
                          onChanged: (v) => setState(() {
                            v == true ? _addOns.add(a.label) : _addOns.remove(a.label);
                          }),
                          activeColor: colors.cinnamon,
                          checkColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(a.label, style: TextStyle(color: colors.latte, fontSize: 14)),
                          secondary: Text('+${peso(a.price)}', style: TextStyle(color: colors.gold)),
                        ),
                    ],
                    const SizedBox(height: 12),
                    Text('Special requests', style: serif(context, 18)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notes,
                      maxLines: 2,
                      style: TextStyle(color: colors.latte),
                      decoration: InputDecoration(
                        hintText: 'Flavors for your box, allergies, message card...',
                        hintStyle: TextStyle(color: colors.oat.withValues(alpha: 0.6), fontSize: 13),
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
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: colors.espressoDark,
                  border: Border(top: BorderSide(color: colors.line)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      QuantityStepper(
                        value: _quantity,
                        onChanged: (v) => setState(() => _quantity = v),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: canOrder ? 'Add · ${peso(_unitPrice * _quantity)}' : 'Out of stock',
                          onPressed: canOrder ? _addToCart : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(AppColors colors, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: colors.gold.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: colors.gold.withValues(alpha: 0.6)),
    ),
    child: Text(text, style: TextStyle(color: colors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
