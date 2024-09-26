import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSONデータのパースに使用
import 'dart:async'; // デバウンス処理に使用
import 'home.dart'; // home.dartのインポート
import 'nav_bar.dart'; // カスタムナビゲーションバーのインポート
import 'filter_modal.dart'; // フィルターモーダルのインポート
import 'aitaku_condition.dart'; // 正しいパスに変更

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
  bool isLoading = false;
  Timer? _debounce;
  late TabController _tabController;
  Map<String, dynamic> filters = {};

  int _selectedIndex = 0; // 現在の選択されたタブのインデックス

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = query;
        fetchEvents();
      });
    });
  }

  void _applyFilters(Map<String, dynamic> appliedFilters) {
    setState(() {
      filters = appliedFilters;
      fetchEvents();
    });
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, String> queryParams = {
        'query': searchQuery,
        if (filters.containsKey('genre') && filters['genre'].isNotEmpty)
          'genre_2': filters['genre'].join(','),
        if (filters.containsKey('region') && filters['region'].isNotEmpty)
          'prefectures': filters['region'].join(','),
        if (filters.containsKey('startDate'))
          'start_time': filters['startDate'].toString().split(' ')[0],
        if (filters.containsKey('endDate'))
          'end_time': filters['endDate'].toString().split(' ')[0],
      };

      Uri uri = Uri.http('15.152.251.125:8000', '/search-events', queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(utf8.decode(response.bodyBytes))['events'];
        setState(() {
          events = data.map((json) => Event.fromJson(json)).toList();
          sortEvents();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void sortEvents() {
    if (_tabController.index == 0) {
      events.sort((a, b) => b.startTime.compareTo(a.startTime));
    } else {
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      searchQuery = '';
      events = [];
      filters.clear();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SearchBar(
                onChanged: _onSearchChanged,
                controller: searchController,
                onClear: _clearSearch,
              ),
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    sortEvents();
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
                padding: const EdgeInsets.only(left: 20, top: 8),
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
            bottom: 40,
            left: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 12,
                    offset: const Offset(7, 7),
                  ),
                ],
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilterModal(
                          onApplyFilters: _applyFilters,
                          initialFilters: filters,
                        ),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      _applyFilters(result);
                    }
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none, // アイコンが上部にはみ出るように設定
        children: [
          CustomBottomNavBar(
            items: [
              FABBottomAppBarItem(iconData: Icons.home, text: 'ホーム'),
              FABBottomAppBarItem(iconData: Icons.favorite, text: 'お気に入り'),
              FABBottomAppBarItem(iconData: Icons.schedule, text: '予約一覧'),
              FABBottomAppBarItem(iconData: Icons.phone, text: '緊急SOS'),
            ],
            selectedIndex: _selectedIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              });
            },
            centerItem: const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 40, // アイコンを上部に飛び出すように配置
            left: MediaQuery.of(context).size.width / 2 - 30, // 中央に配置
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EventSelectorPage()),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF0059), // 中央アイコンの背景色を変更
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi, // 中央アイコンをタクシーマークに変更
                      color: Colors.white, // アイコンの色
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'あいタク\nする',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final TextEditingController controller;
  final VoidCallback onClear;

  const SearchBar({
    Key? key,
    required this.onChanged,
    required this.controller,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '公演名・アーティスト名を入力...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
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

  const EventSearchResults({Key? key, required this.events}) : super(key: key);

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

  const EventCard({Key? key, required this.event}) : super(key: key);

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
