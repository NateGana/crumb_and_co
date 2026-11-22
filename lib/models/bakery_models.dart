// Plain data classes used by the bakery menu, cart and orders.

class ProductVariation {
  ProductVariation({required this.label, required this.price, this.units = 1});

  final String label;
  double price;

  // How many pieces of stock one of this variation uses (a box of 6 uses 6).
  final int units;
}

class AddOn {
  const AddOn(this.label, this.price);

  final String label;
  final double price;
}

const List<AddOn> kAllAddOns = [
  AddOn('Extra chocolate chips', 15),
  AddOn('Walnuts', 20),
  AddOn('Extra toppings', 25),
  AddOn('Gift packaging', 30),
];

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.image,
    required this.variations,
    required this.stock,
    this.allergens = '',
    this.bestSeller = false,
    this.isNew = false,
    this.available = true,
    this.discountPercent = 0,
    this.addOns = const [],
  });

  final String id;
  String name;
  String description;
  String category; // Cookies, Brownies, Dessert Boxes or Gift Sets
  String image; // asset path
  List<ProductVariation> variations;
  int stock; // counted in pieces (or boxes for bundles)
  String allergens;
  bool bestSeller;
  bool isNew;
  bool available;
  double discountPercent;
  List<AddOn> addOns;

  bool get isBundle => category == 'Dessert Boxes' || category == 'Gift Sets';

  // Price of a variation after the admin's discount is applied.
  double priceOf(ProductVariation v) =>
      (v.price * (1 - discountPercent / 100)).roundToDouble();

  double get startingPrice => priceOf(variations.first);
}

enum StockLevel { inStock, lowStock, outOfStock }

enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  preparing('Preparing'),
  readyForPickup('Ready for Pickup'),
  outForDelivery('Out for Delivery'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;
}

class CartItem {
  CartItem({
    required this.product,
    required this.variation,
    required this.addOns,
    required this.quantity,
    this.notes = '',
  });

  final Product product;
  final ProductVariation variation;
  final List<AddOn> addOns;
  int quantity;
  final String notes;

  double get unitPrice =>
      product.priceOf(variation) + addOns.fold(0.0, (s, a) => s + a.price);

  double get subtotal => unitPrice * quantity;

  int get unitsUsed => variation.units * quantity;

  bool sameAs(CartItem other) =>
      product.id == other.product.id &&
      variation.label == other.variation.label &&
      notes == other.notes &&
      addOns.map((a) => a.label).join('|') ==
          other.addOns.map((a) => a.label).join('|');
}

class Order {
  Order({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.contact,
    required this.isDelivery,
    required this.address,
    required this.schedule,
    required this.payment,
    required this.notes,
    required this.items,
    required this.deliveryFee,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  final String id;
  final String customerName;
  final String customerEmail;
  final String contact;
  final bool isDelivery;
  final String address;
  final String schedule;
  final String payment;
  final String notes;
  final List<CartItem> items;
  final double deliveryFee;
  final DateTime createdAt;
  OrderStatus status;

  double get itemsTotal => items.fold(0.0, (s, i) => s + i.subtotal);
  double get total => itemsTotal + deliveryFee;
}

class AppUser {
  AppUser({required this.name, required this.email, this.isAdmin = false});

  final String name;
  final String email;
  final bool isAdmin;
}
