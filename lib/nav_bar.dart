import 'package:flutter/material.dart';

// FABBottomAppBarItemを定義
class FABBottomAppBarItem {
  FABBottomAppBarItem({required this.iconData, required this.text});
  IconData iconData;
  String text;
}

// カスタムのBottomNavBar
class CustomBottomNavBar extends StatelessWidget {
  final List<FABBottomAppBarItem> items;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final Widget centerItem; // 中央のアイコン

  const CustomBottomNavBar({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.centerItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(), // 中央にへこみを作る
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildTabItem(
              index: 0,
              iconData: items[0].iconData,
              text: items[0].text,
              isSelected: selectedIndex == 0,
              context: context),
          _buildTabItem(
              index: 1,
              iconData: items[1].iconData,
              text: items[1].text,
              isSelected: selectedIndex == 1,
              context: context),
          const SizedBox(width: 40), // 中央のスペース
          _buildTabItem(
              index: 2,
              iconData: items[2].iconData,
              text: items[2].text,
              isSelected: selectedIndex == 2,
              context: context),
          _buildTabItem(
              index: 3,
              iconData: items[3].iconData,
              text: items[3].text,
              isSelected: selectedIndex == 3,
              context: context),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData iconData,
    required String text,
    required bool isSelected,
    required BuildContext context,
  }) {
    Color color = isSelected ? Colors.blue : Colors.grey;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(iconData, color: color),
            Text(text, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
