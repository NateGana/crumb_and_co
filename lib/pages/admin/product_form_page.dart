import 'package:flutter/material.dart';

import '../../models/bakery_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../orders_page.dart' show confirmDialog;

// Images the owner can pick from. Add new files to assets/images and list them here.
const List<String> kProductImages = [
  'cookie_choc_chip', 'cookie_double_choc', 'cookie_red_velvet', 'cookie_oreo',
  'cookie_biscoff', 'cookie_dark_choc', 'cookie_walnut', 'cookie_white_choc',
  'brownie_classic', 'brownie_dark', 'brownie_walnut', 'brownie_oreo',
  'brownie_biscoff', 'brownie_red_velvet', 'brownie_bites',
  'box_cookie_4', 'box_cookie_6', 'box_cookie_12', 'box_brownie_4',
  'box_brownie_6', 'box_mixed', 'box_gift',
];

const List<String> kProductCategories = ['Cookies', 'Brownies', 'Dessert Boxes', 'Gift Sets'];

// Add a new product, or edit an existing one when [product] is passed in.
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _allergens;
  late final TextEditingController _stock;
  late final TextEditingController _discount;
  late final List<TextEditingController> _prices;
  late final List<ProductVariation> _variations;
  late String _category;
  late String _image;
  late bool _available;
  late bool _best;
  late bool _isNew;

  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _allergens = TextEditingController(text: p?.allergens ?? '');
    _stock = TextEditingController(text: '${p?.stock ?? 0}');
    _discount = TextEditingController(text: '${(p?.discountPercent ?? 0).round()}');
    // Copy the variations so cancelling the form doesn't change the real product.
    _variations = p == null
        ? [ProductVariation(label: 'Single', price: 0)]
        : p.variations.map((v) => ProductVariation(label: v.label, price: v.price, units: v.units)).toList();
    _prices = [for (final v in _variations) TextEditingController(text: v.price.round().toString())];
    _category = p?.category ?? 'Cookies';
    _image = p?.image.split('/').last.replaceAll('.jpg', '') ?? kProductImages.first;
    _available = p?.available ?? true;
    _best = p?.bestSeller ?? false;
    _isNew = p?.isNew ?? true;
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _allergens, _stock, _discount, ..._prices]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    for (var i = 0; i < _variations.length; i++) {
      _variations[i].price = double.tryParse(_prices[i].text) ?? 0;
    }
    final existing = widget.product;
    final addOns = _category == 'Gift Sets'
        ? <AddOn>[]
        : (_category == 'Dessert Boxes' ? const [AddOn('Gift packaging', 30)] : kAllAddOns);
    final product = existing ?? Product(
      id: appState.newProductId(),
      name: '',
      description: '',
      category: _category,
      image: '',
      variations: _variations,
      stock: 0,
    );
    product
      ..name = _name.text.trim()
      ..description = _description.text.trim()
      ..allergens = _allergens.text.trim()
      ..category = _category
      ..image = 'assets/images/$_image.jpg'
      ..variations = _variations
      ..stock = int.tryParse(_stock.text) ?? 0
      ..discountPercent = (double.tryParse(_discount.text) ?? 0).clamp(0, 90).toDouble()
      ..available = _available
      ..bestSeller = _best
      ..isNew = _isNew
      ..addOns = addOns;
    appState.saveProduct(product);
    Navigator.pop(context);
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
    final style = TextStyle(color: colors.latte);

    return Scaffold(
      backgroundColor: colors.espresso,
      appBar: AppBar(
        backgroundColor: colors.espresso,
        iconTheme: IconThemeData(color: colors.gold),
        title: Text(_editing ? 'Edit product' : 'New product', style: serif(context, 20)),
        actions: [
          if (_editing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE57373)),
              onPressed: () async {
                final ok = await confirmDialog(context, 'Delete product?', 'This removes it from the menu.');
                if (ok && context.mounted) {
                  appState.deleteProduct(widget.product!);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1.8,
                    child: ProductImage('assets/images/$_image.jpg'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _image,
                  isExpanded: true,
                  dropdownColor: colors.espressoDark,
                  style: style,
                  decoration: deco('Product image'),
                  items: [for (final i in kProductImages) DropdownMenuItem(value: i, child: Text(i))],
                  onChanged: (v) => setState(() => _image = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  style: style,
                  decoration: deco('Product name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _description, maxLines: 3, style: style, decoration: deco('Description')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  dropdownColor: colors.espressoDark,
                  style: style,
                  decoration: deco('Category'),
                  items: [for (final c in kProductCategories) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),
                Text('Variations and prices (₱)', style: serif(context, 17)),
                const SizedBox(height: 8),
                for (var i = 0; i < _variations.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      controller: _prices[i],
                      keyboardType: TextInputType.number,
                      style: style,
                      decoration: deco(_variations[i].label),
                      validator: (v) => (double.tryParse(v ?? '') ?? -1) <= 0 ? 'Enter a price' : null,
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stock,
                        keyboardType: TextInputType.number,
                        style: style,
                        decoration: deco('Stock quantity'),
                        validator: (v) => (int.tryParse(v ?? '') ?? -1) < 0 ? 'Enter 0 or more' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _discount,
                        keyboardType: TextInputType.number,
                        style: style,
                        decoration: deco('Discount %'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _allergens, maxLines: 2, style: style, decoration: deco('Allergen information')),
                SwitchListTile(
                  value: _available,
                  onChanged: (v) => setState(() => _available = v),
                  activeThumbColor: colors.cinnamon,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Available to customers', style: style),
                ),
                SwitchListTile(
                  value: _best,
                  onChanged: (v) => setState(() => _best = v),
                  activeThumbColor: colors.cinnamon,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Best seller', style: style),
                ),
                SwitchListTile(
                  value: _isNew,
                  onChanged: (v) => setState(() => _isNew = v),
                  activeThumbColor: colors.cinnamon,
                  contentPadding: EdgeInsets.zero,
                  title: Text('New arrival', style: style),
                ),
                const SizedBox(height: 12),
                PrimaryButton(label: 'Save product', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
