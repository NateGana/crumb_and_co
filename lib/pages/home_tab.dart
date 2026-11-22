import 'package:flutter/material.dart';

import '../models/bakery_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

const List<String> kCategories = [
  'All Treats',
  'Cookies',
  'Brownies',
  'Dessert Boxes',
  'Gift Sets',
  'Best Sellers',
];

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.userName});

  final String userName;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning!';
    if (h < 18) return 'Good afternoon!';
    return 'Good evening!';
  }

  Widget _row(BuildContext context, List<Product> items) {
    return SizedBox(
      height: cardRowHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ProductCard(product: items[i], width: 160),
      ),
    );
  }

  void _openMenu(String category) {
    appState.menuCategory.value = category;
    appState.homeTab.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shown = appState.products.where((p) => p.available).toList();
    final best = shown.where((p) => p.bestSeller).toList();
    final fresh = shown.where((p) => p.isNew).toList();
    final offers = shown.where((p) => p.discountPercent > 0).toList();
    final recommended = shown.where((p) => !p.bestSeller && !p.isNew).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Welcome header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(), style: TextStyle(color: colors.oat, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(userName, style: serif(context, 24), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Something sweet is waiting for you.', style: TextStyle(color: colors.oat, fontSize: 13)),
                  ],
                ),
              ),
              ThemeToggleButton(isDark: isDark),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => appState.homeTab.value = 4,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.espressoDark,
                    border: Border.all(color: colors.line),
                  ),
                  child: Icon(Icons.person_rounded, size: 20, color: colors.gold),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),

        // Promotional banner
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ProductImage('assets/images/hero_banner.jpg'),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                        stops: const [0.0, 0.75],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.6,
                          child: Text(
                            'Freshly Baked Happiness.',
                            style: serif(context, 24).copyWith(color: const Color(0xFFF1E4D5)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FractionallySizedBox(
                          widthFactor: 0.55,
                          child: const Text(
                            'Discover your next favorite cookie or brownie.',
                            style: TextStyle(color: Color(0xFFB8A18B), fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _openMenu('All Treats'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.cinnamon,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Explore Menu'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Categories
        const SectionHeader('Categories'),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ActionChip(
              label: Text(kCategories[i]),
              labelStyle: TextStyle(color: colors.latte, fontSize: 13),
              backgroundColor: colors.espressoDark,
              side: BorderSide(color: colors.line),
              onPressed: () => _openMenu(kCategories[i]),
            ),
          ),
        ),

        SectionHeader('Best Sellers', action: 'See all', onAction: () => _openMenu('Best Sellers')),
        _row(context, best),

        if (fresh.isNotEmpty) ...[
          const SectionHeader('New Arrivals'),
          _row(context, fresh),
        ],

        if (offers.isNotEmpty) ...[
          const SectionHeader('Special Offers'),
          _row(context, offers),
        ],

        if (recommended.isNotEmpty) ...[
          const SectionHeader('Recommended for You'),
          _row(context, recommended),
        ],
      ],
    );
  }
}
