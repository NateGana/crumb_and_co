import 'package:flutter/material.dart';

import '../config/brand.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = appState.user;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Profile', style: serif(context, 26)),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.espressoDark,
              border: Border.all(color: colors.gold, width: 1.5),
            ),
            child: Icon(Icons.person_rounded, size: 42, color: colors.gold),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text(userName, style: serif(context, 22))),
        if (user != null)
          Center(child: Text(user.email, style: TextStyle(color: colors.oat, fontSize: 13))),
        const SizedBox(height: 24),
        _tile(colors, Icons.receipt_long_outlined, 'My orders', '${appState.myOrders.length} placed',
            () => appState.homeTab.value = 3),
        _tile(colors, Icons.shopping_bag_outlined, 'My cart', '${appState.cartCount} items',
            () => appState.homeTab.value = 2),
        _tile(
          colors,
          isDark ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
          'Appearance',
          isDark ? 'Switch to light mode' : 'Switch to dark mode',
          toggleTheme,
        ),
        if (user?.isAdmin ?? false)
          _tile(colors, Icons.dashboard_customize_outlined, 'Business dashboard', 'Manage products and orders',
              () => Navigator.pushNamed(context, '/admin')),
        _tile(colors, Icons.info_outline, 'About ${Brand.name}', Brand.tagline, () {
          showAboutDialog(
            context: context,
            applicationName: Brand.name,
            applicationVersion: '1.0.0',
            children: const [Text(Brand.tagline)],
          );
        }),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              appState.signOut();
              // Clear the stack so Back doesn't return to the shop
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: Icon(Icons.logout_rounded, color: colors.cinnamon, size: 18),
            label: Text('Log out',
                style: TextStyle(color: colors.cinnamon, fontWeight: FontWeight.w600, fontSize: 15)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: colors.cinnamon, width: 1.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tile(AppColors colors, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.espressoDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.line),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: colors.gold),
        title: Text(title, style: TextStyle(color: colors.latte, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.oat, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: colors.oat),
      ),
    );
  }
}
