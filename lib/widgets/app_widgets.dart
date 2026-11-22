import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../config/brand.dart';
import '../models/bakery_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

// Temporarily stores the user's sign-up information for login validation
class TemporaryAuthStore {
  static String? fullName;
  static String? email;
  static String? password;
}

// Underlined, labelled text field styled to match the app theme.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? colors.oat : colors.latte,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: colors.latte, fontSize: 15),
          cursorColor: colors.gold,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.oat.withValues(alpha: 0.5),
              fontSize: 13,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 10),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.line),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.line),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colors.gold, width: 1.4),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
            suffixIcon: suffixIcon,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ],
    );
  }
}

// Circular social-login icon button (Login screen only).
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.espressoDark,
            border: Border.all(color: colors.line),
            boxShadow: [
              BoxShadow(
                color: colors.latte.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: colors.gold),
        ),
      ),
    );
  }
}

// Circular sun/moon button that flips [themeModeNotifier].
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // Changes the app between light and dark mode
        onTap: toggleTheme,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.espressoDark.withValues(alpha: 0.85),
            border: Border.all(color: colors.line),
          ),
          alignment: Alignment.center,
          child: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
            size: 18,
            color: colors.gold,
          ),
        ),
      ),
    );
  }
}

// ---------- Bakery widgets ----------

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

// Asset image that never stretches and falls back to an icon if the path breaks.
class ProductImage extends StatelessWidget {
  const ProductImage(this.path, {super.key, this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: colors.espressoDark,
        alignment: Alignment.center,
        child: Icon(Icons.cookie_rounded, color: colors.gold, size: 36),
      ),
    );
  }
}

TextStyle serif(BuildContext context, double size) =>
    GoogleFonts.dmSerifDisplay(
      fontSize: size,
      color: AppColors.of(context).latte,
    );

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: serif(context, 20))),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Text(action!, style: TextStyle(color: colors.gold)),
            ),
        ],
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  const StockBadge(this.level, {super.key});

  final StockLevel level;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      StockLevel.inStock => ('In Stock', const Color(0xFF6FBF73)),
      StockLevel.lowStock => ('Low Stock', const Color(0xFFE0B15C)),
      StockLevel.outOfStock => ('Out of Stock', const Color(0xFFE57373)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

Color statusColor(OrderStatus s) => switch (s) {
  OrderStatus.pending => const Color(0xFFE0B15C),
  OrderStatus.confirmed => const Color(0xFF64B5F6),
  OrderStatus.preparing => const Color(0xFFE48A45),
  OrderStatus.readyForPickup => const Color(0xFF81C784),
  OrderStatus.outForDelivery => const Color(0xFF4DB6AC),
  OrderStatus.completed => const Color(0xFF6FBF73),
  OrderStatus.cancelled => const Color(0xFFE57373),
};

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.cinnamon,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.line,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    Widget btn(IconData icon, VoidCallback? tap) => InkWell(
      onTap: tap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colors.line),
        ),
        child: Icon(icon, size: 18, color: colors.gold),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove, value > 1 ? () => onChanged(value - 1) : null),
        SizedBox(
          width: 36,
          child: Text('$value', textAlign: TextAlign.center, style: TextStyle(color: colors.latte, fontWeight: FontWeight.w600)),
        ),
        btn(Icons.add, () => onChanged(value + 1)),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.width});

  final Product product;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final level = appState.stockLevel(product);
    return SizedBox(
      width: width,
      child: Material(
        color: colors.espressoDark,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductImage(product.image),
                      if (product.discountPercent > 0 || product.isNew || product.bestSeller)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.cinnamon,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              product.discountPercent > 0
                                  ? '${product.discountPercent.round()}% OFF'
                                  : product.isNew
                                      ? 'NEW'
                                      : 'BEST SELLER',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      if (level == StockLevel.outOfStock)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: const Text('Out of Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.latte, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'from ${peso(product.startingPrice)}',
                            style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Horizontal scroller height that grows a bit when the phone uses larger text.
double cardRowHeight(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
  return 215 + (scale - 1) * 90;
}
