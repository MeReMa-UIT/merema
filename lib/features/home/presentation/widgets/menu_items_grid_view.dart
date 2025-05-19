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
      return const Center(child: Text('An error occurred, please restart the app or re-login.'));
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double crossAxisSpacingVal = 10.0;
            const double mainAxisSpacingVal = 10.0;
            const double calculatedAspectRatio = 1.0;
            const int crossAxisCountVal = 2;
            const ScrollPhysics scrollPhysicsVal = BouncingScrollPhysics();

            return GridView.count(
              crossAxisCount: crossAxisCountVal,
              crossAxisSpacing: crossAxisSpacingVal,
              mainAxisSpacing: mainAxisSpacingVal,
              childAspectRatio: calculatedAspectRatio,
              physics: scrollPhysicsVal,
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
