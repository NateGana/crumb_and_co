# CRUMB & CO.

*A Little Happiness in Every Bite.*

A Flutter cookies and brownies ordering and management app. It was transformed from the original Bloom & Brew coffee shop project and keeps its dark espresso look, login/sign-up flow and theme toggle.

"CRUMB & CO." is a temporary brand name. To rename the shop, edit `lib/config/brand.dart` (and the app label in `android/app/src/main/AndroidManifest.xml`).

## Features

- Login and sign-up (the original in-memory accounts) with a working password visibility toggle
- Customer storefront: promo banner, categories, best sellers, new arrivals, special offers, recommendations
- Bakery menu with search and category filters
- Product details: sizes (single, boxes), add-ons, notes, allergen info, live price
- Cart (quantity, remove, add-ons, subtotal) and checkout (pickup or delivery, date and time, payment option, notes)
- Order tracking with statuses: Pending, Confirmed, Preparing, Ready for Pickup, Out for Delivery, Completed, Cancelled
- Business dashboard: sales stats, order status updates, product and stock management, discounts, customers, settings

## Demo accounts

- Customer: tap "Create an account" on the login screen and sign up with any email and a password of 6+ characters.
- Business owner: `admin@crumbandco.com` / `admin123` opens the admin dashboard.

## Important notes

- All data (accounts, cart, orders, stock changes) is kept in memory and resets when the app restarts. There is no backend or database yet.
- Checkout is a demo. No real payment is processed; payment options are labeled as manual.
- Prices, stock and products in `lib/data/sample_products.dart` are sample data. The images in `assets/images` are simple illustrations; replace them with your own product photos using the same file names.

## Run it in VS Code

1. Install Flutter and the Flutter + Dart extensions for VS Code.
2. Open this folder in VS Code.
3. Run `flutter pub get` in the terminal.
4. Start an Android emulator or connect a phone, then press F5 or run `flutter run`.

## Project structure

```text
lib/
├── main.dart                  routes and theme
├── config/brand.dart          shop name, tagline, peso formatter
├── theme/app_theme.dart       colors and fonts
├── models/bakery_models.dart  Product, CartItem, Order
├── data/sample_products.dart  sample menu
├── state/app_state.dart       cart, orders, stock, reports
├── widgets/app_widgets.dart   shared widgets
└── pages/                     login, sign-up, storefront, cart, checkout, orders, profile, admin/
```
