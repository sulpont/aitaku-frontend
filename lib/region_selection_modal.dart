import 'package:flutter/material.dart';

class RegionSelectionModal extends StatefulWidget {
  final List<String> initialSelectedRegions;
  final Function(List<String>) onRegionsSelected;

  const RegionSelectionModal({
    Key? key,
    required this.initialSelectedRegions,
    required this.onRegionsSelected,
  }) : super(key: key);

  @override
  _RegionSelectionModalState createState() => _RegionSelectionModalState();
}

class _RegionSelectionModalState extends State<RegionSelectionModal> {
  late List<String> selectedRegions;

  // 各地域と対応する都道府県のリスト
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

  final Map<String, bool> expandedRegions = {};

  @override
  void initState() {
    super.initState();
    selectedRegions = List.from(widget.initialSelectedRegions);

    // 各地域の展開状態を初期化
    regionMap.keys.forEach((region) {
      expandedRegions[region] = false;
    });
  }

  // 地域と都道府県の選択状態をトグルする
  void toggleRegion(String region) {
    setState(() {
      expandedRegions[region] = !expandedRegions[region]!; // 展開状態をトグル
    });
  }

  void togglePrefecture(String prefecture) {
    setState(() {
      if (selectedRegions.contains(prefecture)) {
        selectedRegions.remove(prefecture);
      } else {
        selectedRegions.add(prefecture);
      }
    });
  }

  void resetSelection() {
    setState(() {
      selectedRegions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('地域を選ぶ'),
        actions: [
          TextButton(
            onPressed: resetSelection,
            child: const Text('条件リセット'),
          ),
        ],
      ),
      body: ListView(
        children: regionMap.keys.map((region) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(region),
                trailing: Icon(
                  expandedRegions[region]!
                      ? Icons.expand_less
                      : Icons.expand_more,
                ),
                onTap: () => toggleRegion(region),
              ),
              if (expandedRegions[region]!)
                Column(
                  children: regionMap[region]!.map((prefecture) {
                    return CheckboxListTile(
                      title: Text(prefecture),
                      value: selectedRegions.contains(prefecture),
                      onChanged: (_) => togglePrefecture(prefecture),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
            ],
          );
        }).toList(),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onRegionsSelected(selectedRegions);
                Navigator.pop(context);
              },
              child: const Text('検索する'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
