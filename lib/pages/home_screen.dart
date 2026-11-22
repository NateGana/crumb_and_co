import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'cart_page.dart';
import 'home_tab.dart';
import 'menu_tab.dart';
import 'orders_page.dart';
import 'profile_page.dart';

// Customer storefront: bottom navigation with Home, Menu, Cart, Orders and Profile.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // Name passed through Navigator arguments from the login / sign-up screens.
    final args = ModalRoute.of(context)?.settings.arguments;
    final fallbackName = (args is String && args.trim().isNotEmpty) ? args.trim() : 'Friend';
    final userName = appState.user?.name ?? fallbackName;

    return Scaffold(
      backgroundColor: colors.espresso,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) => ValueListenableBuilder<int>(
              valueListenable: appState.homeTab,
              builder: (context, tab, _) {
                return Scaffold(
                  backgroundColor: colors.espresso,
                  body: SafeArea(
                    child: IndexedStack(
                      index: tab,
                      children: [
                        HomeTab(userName: userName),
                        const MenuTab(),
                        const CartPage(),
                        const OrdersPage(),
                        ProfilePage(userName: userName),
                      ],
                    ),
                  ),
                  bottomNavigationBar: NavigationBar(
                    backgroundColor: colors.espressoDark,
                    indicatorColor: colors.cinnamon.withValues(alpha: 0.25),
                    selectedIndex: tab,
                    onDestinationSelected: (i) => appState.homeTab.value = i,
                    destinations: [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined, color: colors.oat),
                        selectedIcon: Icon(Icons.home_rounded, color: colors.gold),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.cookie_outlined, color: colors.oat),
                        selectedIcon: Icon(Icons.cookie_rounded, color: colors.gold),
                        label: 'Menu',
                      ),
                      NavigationDestination(
                        icon: Badge(
                          isLabelVisible: appState.cartCount > 0,
                          label: Text('${appState.cartCount}'),
                          child: Icon(Icons.shopping_bag_outlined, color: colors.oat),
                        ),
                        selectedIcon: Icon(Icons.shopping_bag_rounded, color: colors.gold),
                        label: 'Cart',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.receipt_long_outlined, color: colors.oat),
                        selectedIcon: Icon(Icons.receipt_long_rounded, color: colors.gold),
                        label: 'Orders',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline, color: colors.oat),
                        selectedIcon: Icon(Icons.person_rounded, color: colors.gold),
                        label: 'Profile',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
