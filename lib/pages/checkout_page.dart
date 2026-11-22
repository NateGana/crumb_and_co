import 'package:flutter/material.dart';

import '../config/brand.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: appState.user?.name ?? '');
  final _contact = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();

  bool _delivery = false;
  DateTime? _date;
  TimeOfDay? _time;
  String _payment = 'Cash on pickup / delivery';

  // There is no real payment gateway in this app, so these are manual options.
  static const _payments = [
    'Cash on pickup / delivery',
    'GCash (manual payment)',
    'Bank transfer (manual payment)',
  ];

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null || _time == null) {
      showSnack(context, 'Please choose a preferred date and time.');
      return;
    }
    final schedule =
        '${_date!.year}-${_two(_date!.month)}-${_two(_date!.day)}, ${_time!.format(context)}';
    final error = appState.placeOrder(
      name: _name.text.trim(),
      contact: _contact.text.trim(),
      isDelivery: _delivery,
      address: _delivery ? _address.text.trim() : '',
      schedule: schedule,
      payment: _payment,
      notes: _notes.text.trim(),
    );
    if (error != null) {
      showSnack(context, error);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final colors = AppColors.of(ctx);
        return AlertDialog(
          backgroundColor: colors.espressoDark,
          title: Text('Order placed!', style: serif(ctx, 22)),
          content: Text(
            'Thank you! The bakery will confirm your order soon. '
            'No payment has been taken, so please pay using the option you chose.',
            style: TextStyle(color: colors.oat),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('View my orders', style: TextStyle(color: colors.gold)),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    appState.homeTab.value = 3;
    Navigator.pop(context);
  }

  InputDecoration _decoration(AppColors colors, String label) => InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fee = _delivery ? appState.deliveryFee : 0.0;
    final total = appState.cartSubtotal + fee;

    return Scaffold(
      backgroundColor: colors.espresso,
      appBar: AppBar(
        backgroundColor: colors.espresso,
        iconTheme: IconThemeData(color: colors.gold),
        title: Text('Checkout', style: serif(context, 20)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                TextFormField(
                  controller: _name,
                  style: TextStyle(color: colors.latte),
                  decoration: _decoration(colors, 'Customer name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contact,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: colors.latte),
                  decoration: _decoration(colors, 'Contact number'),
                  validator: (v) =>
                      (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10) ? 'Enter a valid contact number' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Pickup'), icon: Icon(Icons.storefront_outlined)),
                      ButtonSegment(value: true, label: Text('Delivery'), icon: Icon(Icons.delivery_dining_outlined)),
                    ],
                    selected: {_delivery},
                    onSelectionChanged: (s) => setState(() => _delivery = s.first),
                  ),
                ),
                if (_delivery) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    maxLines: 2,
                    style: TextStyle(color: colors.latte),
                    decoration: _decoration(colors, 'Delivery address'),
                    validator: (v) => (v == null || v.trim().length < 8) ? 'Enter your full delivery address' : null,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: Icon(Icons.calendar_today_outlined, size: 18, color: colors.gold),
                        label: Text(
                          _date == null ? 'Pick date' : '${_date!.month}/${_date!.day}/${_date!.year}',
                          style: TextStyle(color: colors.latte),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: colors.line),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: Icon(Icons.schedule, size: 18, color: colors.gold),
                        label: Text(
                          _time == null ? 'Pick time' : _time!.format(context),
                          style: TextStyle(color: colors.latte),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: colors.line),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Payment method', style: serif(context, 18)),
                const SizedBox(height: 4),
                for (final p in _payments)
                  ListTile(
                    onTap: () => setState(() => _payment = p),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      p == _payment ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: p == _payment ? colors.cinnamon : colors.oat,
                    ),
                    title: Text(p, style: TextStyle(color: colors.latte, fontSize: 14)),
                  ),
                Text(
                  'Demo checkout: no real payment is processed. Pay the bakery directly using your chosen option.',
                  style: TextStyle(color: colors.oat, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  style: TextStyle(color: colors.latte),
                  decoration: _decoration(colors, 'Order notes (optional)'),
                ),
                const SizedBox(height: 20),
                Text('Order summary', style: serif(context, 18)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.espressoDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.line),
                  ),
                  child: Column(
                    children: [
                      for (final i in appState.cart)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text('${i.quantity}× ${i.product.name} (${i.variation.label})',
                                    style: TextStyle(color: colors.latte, fontSize: 13)),
                              ),
                              const SizedBox(width: 8),
                              Text(peso(i.subtotal), style: TextStyle(color: colors.latte, fontSize: 13)),
                            ],
                          ),
                        ),
                      Divider(color: colors.line),
                      _line(colors, 'Subtotal', peso(appState.cartSubtotal)),
                      _line(colors, 'Delivery fee', _delivery ? peso(fee) : '—'),
                      const SizedBox(height: 4),
                      _line(colors, 'Total', peso(total), bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Place order', onPressed: _placeOrder),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _line(AppColors colors, String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colors.oat, fontWeight: bold ? FontWeight.w700 : null)),
        Text(value,
            style: TextStyle(
              color: bold ? colors.gold : colors.latte,
              fontWeight: bold ? FontWeight.w700 : null,
              fontSize: bold ? 17 : 14,
            )),
      ],
    ),
  );
}
