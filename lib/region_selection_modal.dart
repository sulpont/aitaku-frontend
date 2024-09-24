import 'package:flutter/material.dart';

class RegionSelectionPage extends StatefulWidget {
  final List<String> initialSelectedRegions;
  final Function(List<String>) onRegionsSelected;

  const RegionSelectionPage({
    Key? key,
    required this.initialSelectedRegions,
    required this.onRegionsSelected,
  }) : super(key: key);

  @override
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  late List<String> selectedRegions;
  List<String> expandedCategories = [];

  final Map<String, List<String>> regionMap = {
    '北海道': ['北海道'],
    '東北': ['青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県'],
    '関東': ['茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県'],
    '東海': ['岐阜県', '静岡県', '愛知県', '三重県'],
    '北信越': ['新潟県', '富山県', '石川県', '福井県', '長野県'],
    '関西': ['滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県'],
    '中国': ['鳥取県', '島根県', '岡山県', '広島県', '山口県'],
    '四国': ['徳島県', '香川県', '愛媛県', '高知県'],
    '九州・沖縄': ['福岡県', '佐賀県', '長崎県', '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県'],
  };

  @override
  void initState() {
    super.initState();
    selectedRegions = List<String>.from(widget.initialSelectedRegions);
  }

  void toggleCategoryExpansion(String category) {
    setState(() {
      if (expandedCategories.contains(category)) {
        expandedCategories.remove(category);
      } else {
        expandedCategories.add(category);
      }
    });
  }

  void toggleRegionSelection(String region) {
    setState(() {
      if (selectedRegions.contains(region)) {
        selectedRegions.remove(region);
      } else {
        selectedRegions.add(region);
      }
    });
  }

  bool isCategoryIndeterminate(List<String> subRegions) {
    int selectedCount = subRegions
        .where((subRegion) => selectedRegions.contains(subRegion))
        .length;
    return selectedCount > 0 && selectedCount < subRegions.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5), // 薄いグレーの背景色
        title: const Text(
          '地域を選ぶ',
          style: TextStyle(color: Colors.black), // 黒い文字色
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedRegions.clear(); // 選択状態をリセット
              });
            },
            child: const Text(
              '条件リセット',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        color: Colors.white, // 背景を白に設定
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: regionMap.length,
                itemBuilder: (context, index) {
                  final category = regionMap.keys.elementAt(index);
                  final subRegions = regionMap[category]!;
                  final isExpanded = expandedCategories.contains(category);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF0059), // 指定色に変更
                          ),
                        ),
                        trailing: Checkbox(
                          tristate: true, // indeterminate状態をサポート
                          value: subRegions.every((subRegion) =>
                                  selectedRegions.contains(subRegion))
                              ? true
                              : isCategoryIndeterminate(subRegions)
                                  ? null
                                  : false,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedRegions.addAll(subRegions);
                              } else {
                                selectedRegions.removeWhere(
                                    (region) => subRegions.contains(region));
                              }
                            });
                          },
                        ),
                        leading: GestureDetector(
                          onTap: () => toggleCategoryExpansion(category),
                          child: Icon(
                            isExpanded ? Icons.remove : Icons.add,
                            color: Colors.black, // プラス・マイナスアイコンを黒字に
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Column(
                          children: subRegions.map((subRegion) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: ListTile(
                                title: Text(subRegion),
                                trailing: Checkbox(
                                  value: selectedRegions.contains(subRegion),
                                  onChanged: (bool? value) {
                                    toggleRegionSelection(subRegion);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity, // ボタンの幅を元に戻す
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15), // 控えめなドロップシャドウ
                      spreadRadius: 1,
                      blurRadius: 12,
                      offset: const Offset(7, 7), // 右と下にドロップシャドウ
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onRegionsSelected(selectedRegions);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 白い太字に設定
                    ),
                  ),
                  child: const Text(
                    '選択する',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
