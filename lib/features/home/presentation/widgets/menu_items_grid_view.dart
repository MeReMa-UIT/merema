import 'package:flutter/material.dart';
import 'package:merema/features/home/presentation/pages/home_page.dart';
import 'package:merema/features/home/presentation/widgets/menu_card.dart';

class MenuItemsGridView extends StatelessWidget {
  final List<MenuItemConfig> currentMenuItems;

  const MenuItemsGridView({
    super.key,
    required this.currentMenuItems,
  });

  @override
  Widget build(BuildContext context) {
    if (currentMenuItems.isEmpty) {
      return const Center(child: Text('Cannot load menu items.'));
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double crossAxisSpacing = 10.0;
            const double mainAxisSpacing = 10.0;

            int crossAxisCount;
            double aspectRatio;
            bool canFitAllCards = false;

            if (constraints.maxWidth < 400) {
              crossAxisCount = 1;
              aspectRatio = 1.0;
            } else if (constraints.maxWidth < 700) {
              crossAxisCount = 2;
              aspectRatio = 1.0;
            } else {
              crossAxisCount = 3;
              double cardWidth =
                  (constraints.maxWidth - 32 - crossAxisSpacing * 2) / 3;
              double cardHeight =
                  (constraints.maxHeight - 32 - mainAxisSpacing) / 2;
              aspectRatio = cardWidth / cardHeight;
              aspectRatio = aspectRatio.isFinite ? aspectRatio : 1.0;

              int rowsNeeded = (currentMenuItems.length + crossAxisCount - 1) ~/
                  crossAxisCount;
              double totalHeight =
                  rowsNeeded * cardHeight + (rowsNeeded - 1) * mainAxisSpacing;
              canFitAllCards = totalHeight <= constraints.maxHeight - 32;
            }

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: aspectRatio,
              physics: canFitAllCards
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              shrinkWrap: canFitAllCards,
              children: currentMenuItems.map((item) {
                return MenuCard(
                  title: item.title,
                  icon: item.icon,
                  onTap: () => item.onTap(context),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
