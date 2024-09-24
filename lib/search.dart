import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON データのパースに使用
import 'dart:async'; // デバウンス処理に使用
import 'home.dart'; // home.dartのインポート
import 'nav_bar.dart';
import 'aitaku_condition.dart';
import 'filter_modal.dart';

class EventSelectorPage extends StatefulWidget {
  const EventSelectorPage({Key? key}) : super(key: key);

  @override
  _EventSelectorPageState createState() => _EventSelectorPageState();
}

class _EventSelectorPageState extends State<EventSelectorPage>
    with TickerProviderStateMixin {
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  List<Event> events = [];
  bool isLoading = false; // ローディングインジケーター表示用
  Timer? _debounce; // デバウンス用タイマー
  late TabController _tabController; // タブコントローラー

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: 1); // デフォルトで「公演日が早い順」を選択
  }

  // デバウンス付きの検索メソッド
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel(); // 既存のタイマーをキャンセル

    // クエリが空の場合、イベントをクリアして「検索結果がありません」を表示
    if (query.isEmpty) {
      setState(() {
        events = [];
        searchQuery = '';
        isLoading = false; // ローディングを停止
      });
      return;
    }

    // デバウンス: ユーザーが入力し終わってから500ミリ秒後に検索実行
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
        fetchEvents(); // クエリがある場合のみ検索を実行
      });
    });
  }

  // APIからイベントデータを取得するメソッド
  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true; // ローディング中
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://15.152.251.125:8000/search-events?query=$searchQuery'), // 適切なAPIエンドポイントを使用
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json
            .decode(utf8.decode(response.bodyBytes))['events']; // UTF-8にデコード
        setState(() {
          events = data.map((json) => Event.fromJson(json)).toList();
          sortEvents(); // ソートを実行
          isLoading = false; // ローディング終了
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false; // エラー時もローディング終了
      });
    }
  }

  // イベントのソートメソッド
  void sortEvents() {
    if (_tabController.index == 0) {
      // 公演日が遅い順にソート
      events.sort((a, b) => b.startTime.compareTo(a.startTime));
    } else {
      // 公演日が早い順にソート
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
  }

  // 検索フィールドをクリアするメソッド
  void _clearSearch() {
    searchController.clear(); // テキストフィールドをクリア
    setState(() {
      searchQuery = '';
      events = []; // 検索結果をリセット
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // 画面破棄時にタイマーをキャンセル
    _tabController.dispose(); // タブコントローラーの破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 背景色を白に統一
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text('イベントを選ぶ', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF5F5F5), // 薄いグレー
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SearchBar(
                onChanged: _onSearchChanged,
                controller: searchController, // テキストコントローラーを渡す
                onClear: _clearSearch, // クリアボタンの処理
              ),
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    sortEvents(); // タブが変更されたときにソートを更新
                  });
                },
                tabs: const [
                  Tab(text: '公演日が遅い順'),
                  Tab(text: '公演日が早い順'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8), // 件数表示を少し右に移動
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${events.length}件',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : events.isEmpty
                        ? const Center(child: Text('検索結果がありません'))
                        : EventSearchResults(events: events),
              ),
            ],
          ),
          Positioned(
            bottom: 24, // ボタンをNavBarに近いが少し上に配置
            left: MediaQuery.of(context).size.width * 0.25, // 横位置をセンターに
            child: Container(
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5, // ボタン幅を半分に調整
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilterModal(
                          onApplyFilters: (filters) {
                            // フィルターが適用された時の処理
                            // TODO: ここにフィルター適用後の処理を記述
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '絞り込み検索',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // 太字に設定
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final TextEditingController controller;
  final VoidCallback onClear;

  const SearchBar({
    super.key,
    required this.onChanged,
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged, // 入力イベントのたびにコールバックを呼び出す
        decoration: InputDecoration(
          hintText: '公演名・アーティスト名を入力...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear, // クリアボタンを押すとフィールドをクリア
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class EventSearchResults extends StatelessWidget {
  final List<Event> events;

  const EventSearchResults({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(event: event);
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: const Center(
                child: Text('画像'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(event.artist),
                  const SizedBox(height: 4),
                  Text(event.venue),
                  const SizedBox(height: 4),
                  Text('${event.startTime} / ${event.endTime}'),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AiTakuConditionSpecification()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.pink,
                  ),
                  child: const Icon(
                    Icons.local_taxi,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                  color: Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final String artist;
  final String venue;
  final String startTime;
  final String endTime;
  final String imageUrl;

  Event({
    required this.title,
    required this.artist,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['event_title'],
      artist: json['artist_name'] ?? '不明',
      venue: json['event_venue'],
      startTime: json['start_time'],
      endTime: json['end_time'] ?? '不明',
      imageUrl: json['picture_path'] ?? '',
    );
  }
}
