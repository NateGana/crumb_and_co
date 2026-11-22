import 'package:flutter/material.dart';

import '../data/sample_products.dart';
import '../models/bakery_models.dart';

// One shared store for the menu, cart and orders. Data lives in memory only,
// the same way the original sign-up store works, so it resets on app restart.
class AppState extends ChangeNotifier {
  AppState._() {
    _seedDemoOrders();
  }

  static final AppState instance = AppState._();

  // Demo admin account for testing the business owner screens.
  static const String adminEmail = 'admin@crumbandco.com';
  static const String adminPassword = 'admin123';

  final List<Product> products = buildSampleProducts();
  final List<CartItem> cart = [];
  final List<Order> orders = [];
  final List<AppUser> registeredUsers = [];

  AppUser? user;
  double deliveryFee = 50;
  int lowStockLimit = 10;
  String businessPhone = '0917 000 0000';

  // Bottom tab shown on the customer home screen, and the menu filter.
  final ValueNotifier<int> homeTab = ValueNotifier(0);
  final ValueNotifier<String> menuCategory = ValueNotifier('All Treats');

  int _orderCounter = 1003;
  int _productCounter = 100;

  // ---------- Session ----------
  void signIn(AppUser u) {
    user = u;
    homeTab.value = 0;
    notifyListeners();
  }

  void signOut() {
    user = null;
    cart.clear();
    homeTab.value = 0;
    menuCategory.value = 'All Treats';
    notifyListeners();
  }

  // ---------- Stock ----------
  StockLevel stockLevel(Product p) {
    if (!p.available || p.stock <= 0) return StockLevel.outOfStock;
    if (p.stock <= lowStockLimit) return StockLevel.lowStock;
    return StockLevel.inStock;
  }

  int _unitsInCart(Product p, {CartItem? except}) => cart
      .where((c) => c.product.id == p.id && c != except)
      .fold(0, (s, c) => s + c.unitsUsed);

  // How many more units of this product can still be added to the cart.
  int unitsLeftFor(Product p) => p.stock - _unitsInCart(p);

  // ---------- Cart ----------
  // Returns an error message, or null when the item was added.
  String? addToCart(CartItem item) {
    final needed = item.unitsUsed;
    if (!item.product.available || item.product.stock <= 0) {
      return '${item.product.name} is out of stock.';
    }
    if (needed > unitsLeftFor(item.product)) {
      return 'Only ${unitsLeftFor(item.product)} left in stock for ${item.product.name}.';
    }
    for (final existing in cart) {
      if (existing.sameAs(item)) {
        existing.quantity += item.quantity;
        notifyListeners();
        return null;
      }
    }
    cart.add(item);
    notifyListeners();
    return null;
  }

  String? setQuantity(CartItem item, int quantity) {
    if (quantity < 1) return null;
    final others = _unitsInCart(item.product, except: item);
    if (others + item.variation.units * quantity > item.product.stock) {
      return 'Not enough stock for that quantity.';
    }
    item.quantity = quantity;
    notifyListeners();
    return null;
  }

  void removeFromCart(CartItem item) {
    cart.remove(item);
    notifyListeners();
  }

  int get cartCount => cart.fold(0, (s, c) => s + c.quantity);
  double get cartSubtotal => cart.fold(0.0, (s, c) => s + c.subtotal);

  // ---------- Orders ----------
  // Returns an error message, or null when the order was saved.
  String? placeOrder({
    required String name,
    required String contact,
    required bool isDelivery,
    required String address,
    required String schedule,
    required String payment,
    required String notes,
  }) {
    if (cart.isEmpty) return 'Your cart is empty.';
    // Re-check stock right before saving so it can never go below zero.
    final need = <String, int>{};
    for (final c in cart) {
      need[c.product.id] = (need[c.product.id] ?? 0) + c.unitsUsed;
    }
    for (final c in cart) {
      if (!c.product.available || need[c.product.id]! > c.product.stock) {
        return '${c.product.name} no longer has enough stock. Please update your cart.';
      }
    }
    for (final c in cart) {
      c.product.stock -= c.unitsUsed;
    }
    orders.insert(
      0,
      Order(
        id: 'CC-${_orderCounter++}',
        customerName: name,
        customerEmail: user?.email ?? '',
        contact: contact,
        isDelivery: isDelivery,
        address: address,
        schedule: schedule,
        payment: payment,
        notes: notes,
        items: List.of(cart),
        deliveryFee: isDelivery ? deliveryFee : 0,
        createdAt: DateTime.now(),
      ),
    );
    cart.clear();
    notifyListeners();
    return null;
  }

  List<Order> get myOrders =>
      orders.where((o) => o.customerEmail == user?.email).toList();

  // Refresh the order list after the admin changes its status.
  void updateStatus(Order order, OrderStatus status) {
    if (order.status == status || order.status == OrderStatus.cancelled) return;
    if (status == OrderStatus.cancelled) {
      // Put the pieces back on the shelf when an order is cancelled.
      for (final c in order.items) {
        c.product.stock += c.unitsUsed;
      }
    }
    order.status = status;
    notifyListeners();
  }

  // ---------- Admin: products ----------
  String newProductId() => 'p${_productCounter++}';

  void saveProduct(Product p) {
    if (!products.any((x) => x.id == p.id)) products.add(p);
    notifyListeners();
  }

  void deleteProduct(Product p) {
    products.remove(p);
    cart.removeWhere((c) => c.product.id == p.id);
    notifyListeners();
  }

  void changeStock(Product p, int delta) {
    p.stock = (p.stock + delta).clamp(0, 9999);
    notifyListeners();
  }

  void touch() => notifyListeners();

  // ---------- Admin: reports ----------
  List<Order> get _countedOrders =>
      orders.where((o) => o.status != OrderStatus.cancelled).toList();

  double get totalSales => _countedOrders.fold(0.0, (s, o) => s + o.total);
  int get totalOrders => orders.length;
  int countByStatus(OrderStatus s) => orders.where((o) => o.status == s).length;
  int get lowStockCount => products
      .where((p) => stockLevel(p) != StockLevel.inStock)
      .length;

  // Units sold per product name for one category, highest first.
  List<MapEntry<String, int>> bestSelling(String category) {
    final sold = <String, int>{};
    for (final o in _countedOrders) {
      for (final i in o.items) {
        if (i.product.category == category) {
          sold[i.product.name] = (sold[i.product.name] ?? 0) + i.quantity;
        }
      }
    }
    final list = sold.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list.take(3).toList();
  }

  Map<String, double> salesByCategory() {
    final map = <String, double>{};
    for (final o in _countedOrders) {
      for (final i in o.items) {
        map[i.product.category] = (map[i.product.category] ?? 0) + i.subtotal;
      }
    }
    return map;
  }

  // Customers are built from registered accounts plus anyone who has ordered.
  List<CustomerSummary> get customers {
    final map = <String, CustomerSummary>{};
    for (final u in registeredUsers) {
      map[u.email] = CustomerSummary(u.name, u.email, '');
    }
    for (final o in orders) {
      final c = map.putIfAbsent(
        o.customerEmail,
        () => CustomerSummary(o.customerName, o.customerEmail, o.contact),
      );
      if (o.contact.isNotEmpty) c.contact = o.contact;
      c.orders++;
      if (o.status != OrderStatus.cancelled) c.spent += o.total;
    }
    return map.values.toList();
  }

  // A few sample orders so the admin dashboard has something to show.
  void _seedDemoOrders() {
    Product p(String id) => products.firstWhere((x) => x.id == id);
    CartItem item(String id, int variation, int qty) => CartItem(
      product: p(id),
      variation: p(id).variations[variation],
      addOns: const [],
      quantity: qty,
    );
    final now = DateTime.now();
    orders.addAll([
      Order(
        id: 'CC-1002',
        customerName: 'Demo Customer',
        customerEmail: 'demo@customer.com',
        contact: '0917 123 4567',
        isDelivery: true,
        address: 'Sample Street, Cabuyao, Laguna',
        schedule: 'Tomorrow, 2:00 PM',
        payment: 'GCash (manual payment)',
        notes: '',
        items: [item('c1', 2, 1), item('b1', 1, 1)],
        deliveryFee: 50,
        createdAt: now.subtract(const Duration(hours: 5)),
        status: OrderStatus.preparing,
      ),
      Order(
        id: 'CC-1001',
        customerName: 'Demo Customer',
        customerEmail: 'demo@customer.com',
        contact: '0917 123 4567',
        isDelivery: false,
        address: '',
        schedule: 'Yesterday, 4:00 PM',
        payment: 'Cash on pickup',
        notes: 'No nuts please',
        items: [item('x2', 0, 1), item('c4', 0, 2)],
        deliveryFee: 0,
        createdAt: now.subtract(const Duration(days: 1)),
        status: OrderStatus.completed,
      ),
    ]);
  }
}

class CustomerSummary {
  CustomerSummary(this.name, this.email, this.contact);
  final String name;
  final String email;
  String contact;
  int orders = 0;
  double spent = 0;
}

final AppState appState = AppState.instance;
