import 'package:flutter/material.dart';
import 'filter_modal.dart';
import 'aitaku_condition.dart'; // この行を追加

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Selector App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const EventSelectorPage(),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'ホーム', Colors.blue),
            _buildNavItem(Icons.favorite_border, 'お気に入り', Colors.black),
            const SizedBox(
              width: 60,
              child: Text(
                'あいタク',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
            _buildNavItem(Icons.access_time, '予約一覧', Colors.black),
            _buildNavItem(Icons.phone, '緊急SOS', Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class EventSelectorPage extends StatefulWidget {
  const EventSelectorPage({Key? key}) : super(key: key);

  @override
  _EventSelectorPageState createState() => _EventSelectorPageState();
}

class _EventSelectorPageState extends State<EventSelectorPage> {
  String searchQuery = '';
  Map<String, dynamic> appliedFilters = {};

  List<Event> events = [
    Event(
      title: 'TWICE 5TH WORLD TOUR \'READY TO BE\'',
      artist: 'TWICE',
      venue: '神奈川/日産スタジアム',
      date: '2024年7月27日（土）',
      time: '16:00 開場 18:00 開演',
      imageUrl: '',
    ),
    Event(
      title: 'TWICE 5TH WORLD TOUR \'READY TO BE\'',
      artist: 'TWICE',
      venue: '神奈川/日産スタジアム',
      date: '2024年7月28日（日）',
      time: '15:00 開場 17:00 開演',
      imageUrl: '',
    ),
    // 他のイベントをここに追加
  ];

  List<Event> get filteredEvents {
    return events
        .where((event) =>
            event.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            event.artist.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      appliedFilters = filters;
      // ここでフィルターに基づいてイベントリストを更新
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text('イベントを選ぶ', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          const EventStatusIndicator(),
          SearchBar(
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
          Expanded(
            child: searchQuery.isEmpty
                ? const RecentSearches()
                : EventSearchResults(
                    searchQuery: searchQuery,
                    events: filteredEvents,
                    onFilterApplied: _applyFilters),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterModal, // モーダル表示関数を呼び出し
        backgroundColor: Colors.pink,
        child: const Icon(
          Icons.local_taxi,
          size: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        onApplyFilters: (filters) {
          setState(() {
            appliedFilters = filters;
            // フィルター適用後の処理
          });
        },
      ),
    );
  }
}

class EventStatusIndicator extends StatelessWidget {
  const EventStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(); // 仮の実装
  }
}

class SearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: '公演名・アーティスト名を入力...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.mic),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class RecentSearches extends StatelessWidget {
  const RecentSearches({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('最近の検索', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildSearchItem('fromis_9'),
        _buildSearchItem('Kepler'),
        _buildSearchItem('IVE'),
        _buildSearchItem('BLACKPINK'),
        _buildSearchItem('aespa'),
      ],
    );
  }

  Widget _buildSearchItem(String text) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(text),
      onTap: () {},
    );
  }
}

class EventSearchResults extends StatelessWidget {
  final String searchQuery;
  final List<Event> events;
  final Function(Map<String, dynamic>) onFilterApplied;

  const EventSearchResults({
    super.key,
    required this.searchQuery,
    required this.events,
    required this.onFilterApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('公演日が遅い順', style: TextStyle(color: Colors.grey)),
              Text('公演日が早い順', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Text('${events.length}件',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                title: event.title,
                artist: event.artist,
                venue: event.venue,
                date: event.date,
                time: event.time,
                imageUrl: event.imageUrl,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FilterModal(
                  onApplyFilters: onFilterApplied,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.pink,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.pink),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('絞り込み検索'),
          ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String artist;
  final String venue;
  final String date;
  final String time;
  final String imageUrl;

  const EventCard({
    super.key,
    required this.title,
    required this.artist,
    required this.venue,
    required this.date,
    required this.time,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左: 画像部分
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  '画像',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(width: 16), // 画像とテキストの間にスペースを追加

            // 中央: テキスト部分
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(artist),
                  const SizedBox(height: 4),
                  Text(venue),
                  const SizedBox(height: 4),
                  Text('$date / $time'),
                ],
              ),
            ),

            // 右: ボタン部分
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // ここでAiTakuConditionSpecification画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AiTakuConditionSpecification()),
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
  final String date;
  final String time;
  final String imageUrl;

  const Event({
    required this.title,
    required this.artist,
    required this.venue,
    required this.date,
    required this.time,
    required this.imageUrl,
  });
}
