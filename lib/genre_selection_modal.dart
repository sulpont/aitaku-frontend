import 'package:flutter/material.dart';

class GenreSelectionModal extends StatefulWidget {
  final List<String> initialSelectedGenres;
  final Function(List<String>) onGenresSelected;

  const GenreSelectionModal({
    Key? key,
    required this.initialSelectedGenres,
    required this.onGenresSelected,
  }) : super(key: key);

  @override
  _GenreSelectionModalState createState() => _GenreSelectionModalState();
}

class _GenreSelectionModalState extends State<GenreSelectionModal> {
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
        'アソン・歌い手・ボカロ',
        'ゲーム音楽'
      ]
    },
    {
      'category': 'スポーツ',
      'subGenres': ['野球', 'サッカー', 'バスケットボール']
    },
    {
      'category': 'その他',
      'subGenres': ['展示会', 'お笑い', '演劇']
    }
  ];

  @override
  void initState() {
    super.initState();
    selectedGenres = List.from(widget.initialSelectedGenres);
  }

  void toggleCategory(String category) {
    setState(() {
      if (expandedCategories.contains(category)) {
        expandedCategories.remove(category);
      } else {
        expandedCategories.add(category);
      }
    });
  }

  void toggleGenre(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
    });
  }

  void resetSelection() {
    setState(() {
      selectedGenres.clear();
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
        title: const Text('ジャンルを選ぶ'),
        actions: [
          TextButton(
            onPressed: resetSelection,
            child: const Text('条件リセット'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final category = genres[index]['category'] as String;
          final subGenres = genres[index]['subGenres'] as List<String>;
          return Column(
            children: [
              ListTile(
                title: Text(category),
                trailing: Icon(
                  expandedCategories.contains(category)
                      ? Icons.remove
                      : Icons.add,
                ),
                onTap: () => toggleCategory(category),
              ),
              if (expandedCategories.contains(category))
                ...subGenres.map((genre) => CheckboxListTile(
                      title: Text(genre),
                      value: selectedGenres.contains(genre),
                      onChanged: (_) => toggleGenre(genre),
                    )),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            widget.onGenresSelected(selectedGenres);
            Navigator.pop(context);
          },
          child: const Text('検索する'),
        ),
      ),
    );
  }
}
