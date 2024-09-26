import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'genre_selection_modal.dart' as genre; // エイリアスをつける
import 'region_selection_modal.dart' as region; // エイリアスをつける
import 'nav_bar.dart'; // カスタムナビゲーションバーをインポート
import 'home.dart'; // ホーム画面のインポート
import 'search.dart'; // 検索画面のインポート

class FilterModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic>? initialFilters;

  const FilterModal(
      {Key? key, required this.onApplyFilters, this.initialFilters})
      : super(key: key);

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  Map<String, dynamic> filters = {
    'genre': <String>[],
    'region': <String>[],
    'startDate': DateTime.now(),
    'endDate': DateTime.now().add(const Duration(days: 30)),
  };

  bool showStartCalendar = false;
  bool showEndCalendar = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      filters = {
        'genre': widget.initialFilters!['genre'] ?? <String>[],
        'region': widget.initialFilters!['region'] ?? <String>[],
        'startDate': widget.initialFilters!['startDate'] ?? DateTime.now(),
        'endDate': widget.initialFilters!['endDate'] ??
            DateTime.now().add(const Duration(days: 30)),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text(
          '絞り込み検索',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              '条件リセット',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFilterSection(
                          'ジャンル',
                          (filters['genre'] ?? <String>[]).isEmpty
                              ? 'すべて'
                              : filters['genre'].join(', '),
                          _showGenreSelectionModal),
                      _buildFilterSection(
                          '地域',
                          (filters['region'] ?? <String>[]).isEmpty
                              ? 'すべて'
                              : filters['region'].join(', '),
                          _showRegionSelectionPage),
                      _buildDateSection(),
                      if (showStartCalendar) _buildCalendar(true),
                      if (showEndCalendar) _buildCalendar(false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              width: double.infinity, // ボタンの幅を100%に設定
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
                  widget.onApplyFilters(filters);
                  Navigator.pop(context, filters); // フィルタを戻す
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 色をBlueに戻す
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // BorderRadiusを8.0に設定
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                child: const Text(
                  '検索する',
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
      bottomNavigationBar: CustomBottomNavBar(
        items: [
          FABBottomAppBarItem(iconData: Icons.home, text: 'ホーム'),
          FABBottomAppBarItem(iconData: Icons.favorite, text: 'お気に入り'),
          FABBottomAppBarItem(iconData: Icons.schedule, text: '予約一覧'),
          FABBottomAppBarItem(iconData: Icons.phone, text: '緊急SOS'),
        ],
        centerItem: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EventSelectorPage(),
              ),
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF0059), // 中央アイコンの背景色
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_taxi, // 中央アイコンをタクシーマークに設定
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        selectedIndex: 0, // デフォルトで最初のタブを選択
        onTabSelected: (index) {
          setState(() {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterSection(String title, dynamic value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF0059),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value is List ? value.join(', ') : value.toString()),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showGenreSelectionModal() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            genre.GenreSelectionPage(
          initialSelectedGenres: List<String>.from(filters['genre']),
          onGenresSelected: (selectedGenres) {
            setState(() {
              filters['genre'] = selectedGenres;
            });
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 右から左にスライド
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showRegionSelectionPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            region.RegionSelectionPage(
          initialSelectedRegions: List<String>.from(filters['region']),
          onRegionsSelected: (selectedRegions) {
            setState(() {
              filters['region'] = selectedRegions;
            });
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 右から左にスライド
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '公演日',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF0059),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'いつから',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  _buildDateInput(
                    '開始日',
                    filters['startDate'],
                    () =>
                        setState(() => showStartCalendar = !showStartCalendar),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('ー'),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'いつまで',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  _buildDateInput(
                    '終了日',
                    filters['endDate'],
                    () => setState(() => showEndCalendar = !showEndCalendar),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateInput(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('yyyy/MM/dd').format(date)),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(bool isStartDate) {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: isStartDate ? filters['startDate'] : filters['endDate'],
      selectedDayPredicate: (day) => isSameDay(
          isStartDate ? filters['startDate'] : filters['endDate'], day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          if (isStartDate) {
            filters['startDate'] = selectedDay;
            showStartCalendar = false;
          } else {
            filters['endDate'] = selectedDay;
            showEndCalendar = false;
          }
        });
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      filters = {
        'genre': <String>[],
        'region': <String>[],
        'startDate': DateTime.now(),
        'endDate': DateTime.now().add(const Duration(days: 30)),
      };
    });
  }
}
