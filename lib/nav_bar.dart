import 'package:flutter/material.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({required this.iconData, required this.text});
  IconData iconData;
  String text;
}

class CustomBottomNavBar extends StatefulWidget {
  final List<FABBottomAppBarItem> items;
  final Widget centerItem;
  final double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final void Function(int) onTabSelected;
  final int selectedIndex; // 追加: 現在のタブのインデックス
  final TextStyle labelStyle; // 追加: テキストのスタイル

  const CustomBottomNavBar({
    Key? key,
    required this.items,
    required this.centerItem,
    this.height = 60.0,
    this.iconSize = 24.0,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.color = Colors.grey,
    this.selectedColor = Colors.blue,
    required this.onTabSelected,
    required this.selectedIndex, // 追加: 現在のタブのインデックス
    required this.labelStyle, // 追加: テキストのスタイル
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  void _updateIndex(int index) {
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...items.sublist(0, items.length ~/ 2), // 左側のアイテム
          widget.centerItem, // 中央のアイテム
          ...items.sublist(items.length ~/ 2), // 右側のアイテム
        ],
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildTabItem({
    required FABBottomAppBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    Color color =
        widget.selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: InkWell(
          onTap: () => onPressed(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(item.iconData, color: color, size: widget.iconSize),
              const SizedBox(height: 4), // アイコンとテキストの間に少し間隔を追加
              Text(
                item.text,
                style: widget.labelStyle.copyWith(color: color), // テキストのスタイルを適用
              ),
            ],
          ),
        ),
      ),
    );
  }
}
