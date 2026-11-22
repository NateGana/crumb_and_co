import 'package:flutter/material.dart';

import 'config/brand.dart';
import 'pages/admin/admin_screen.dart';
import 'pages/checkout_page.dart';
import 'pages/home_screen.dart';
import 'pages/login_screen.dart';
import 'pages/product_detail_page.dart';
import 'pages/signup_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const CrumbAndCoApp());

class CrumbAndCoApp extends StatelessWidget {
  const CrumbAndCoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: Brand.name,
          debugShowCheckedModeBanner: false,

          // Applies the currently selected light or dark theme
          themeMode: mode,
          theme: buildAppTheme(AppColors.light, Brightness.light),
          darkTheme: buildAppTheme(AppColors.dark, Brightness.dark),

          // Defines the app's named navigation routes
          initialRoute: '/', // Sets the login screen as the starting page
          routes: {
            '/': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/product': (context) => const ProductDetailPage(),
            '/checkout': (context) => const CheckoutPage(),
            '/admin': (context) => const AdminScreen(),
          },
        );
      },
    );
  }
}
