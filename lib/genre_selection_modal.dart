import 'package:flutter/material.dart';

class GenreSelectionPage extends StatefulWidget {
  final List<String> initialSelectedGenres;
  final Function(List<String>) onGenresSelected;

  const GenreSelectionPage({
    Key? key,
    required this.initialSelectedGenres,
    required this.onGenresSelected,
  }) : super(key: key);

  @override
  _GenreSelectionPageState createState() => _GenreSelectionPageState();
}

class _GenreSelectionPageState extends State<GenreSelectionPage> {
  late List<String> selectedGenres;
  List<String> expandedCategories = ['ライブ・コンサート'];

  final List<Map<String, dynamic>> genres = [
    {
      'category': 'ライブ・コンサート',
      'subGenres': [
        'J-POP',
        'K-POP・韓流・アジア',
        'アイドル',
        'メタル・ハードコア',
        'ジャズ・フュージョン',
        'EDM・ダンス・クラブ',
        '声優ライブ',
        'アニソン・歌い手・ボカロ',
        'ゲーム音楽',
      ]
    },
    {
      'category': 'スポーツ',
      'subGenres': ['野球', 'サッカー', 'バスケットボール'],
    },
    {
      'category': 'その他',
      'subGenres': ['展示会', 'お笑い', '演劇'],
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedGenres = List<String>.from(widget.initialSelectedGenres);
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

  void toggleGenreSelection(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
    });
  }

  bool isCategoryIndeterminate(List<String> subGenres) {
    int selectedCount =
        subGenres.where((subGenre) => selectedGenres.contains(subGenre)).length;
    return selectedCount > 0 && selectedCount < subGenres.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5), // 薄いグレーの背景色
        title: const Text(
          'ジャンルを選ぶ',
          style: TextStyle(color: Colors.black), // 黒い文字色
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedGenres.clear();
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
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final category = genres[index]['category'];
                  final subGenres = genres[index]['subGenres'] as List<String>;
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
                          value: subGenres.every((subGenre) =>
                                  selectedGenres.contains(subGenre))
                              ? true
                              : isCategoryIndeterminate(subGenres)
                                  ? null
                                  : false,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedGenres.addAll(subGenres);
                              } else {
                                selectedGenres.removeWhere(
                                    (genre) => subGenres.contains(genre));
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
                          children: subGenres.map((subGenre) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 32.0), // 親カテゴリに揃える
                              child: ListTile(
                                title: Text(subGenre),
                                trailing: Checkbox(
                                  value: selectedGenres.contains(subGenre),
                                  onChanged: (bool? value) {
                                    toggleGenreSelection(subGenre);
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
                    widget.onGenresSelected(selectedGenres);
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
