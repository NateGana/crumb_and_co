import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'home_tab.dart';

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);

    return ValueListenableBuilder<String>(
      valueListenable: appState.menuCategory,
      builder: (context, category, _) {
        final items = appState.products.where((p) {
          if (!p.available) return false;
          final matchesCategory = switch (category) {
            'All Treats' => true,
            'Best Sellers' => p.bestSeller,
            _ => p.category == category,
          };
          final matchesQuery = p.name.toLowerCase().contains(_query.toLowerCase());
          return matchesCategory && matchesQuery;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Bakery Menu', style: serif(context, 26)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: colors.latte),
                decoration: InputDecoration(
                  hintText: 'Search cookies, brownies, boxes',
                  hintStyle: TextStyle(color: colors.oat.withValues(alpha: 0.7), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: colors.gold),
                  filled: true,
                  fillColor: colors.espressoDark,
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: colors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: colors.gold),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = kCategories[i] == category;
                  return ChoiceChip(
                    label: Text(kCategories[i]),
                    selected: selected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : colors.latte,
                      fontSize: 13,
                    ),
                    selectedColor: colors.cinnamon,
                    backgroundColor: colors.espressoDark,
                    side: BorderSide(color: colors.line),
                    onSelected: (_) => appState.menuCategory.value = kCategories[i],
                  );
                },
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text('No treats found.', style: TextStyle(color: colors.oat)),
                    )
                  : LayoutBuilder(
                      builder: (context, box) {
                        // Card height follows the card width so the image never gets squashed.
                        final cardWidth = (box.maxWidth - 52) / 2;
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: cardWidth / 1.25 + 78 * scale,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => ProductCard(product: items[i]),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
