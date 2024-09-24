import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'genre_selection_modal.dart' as genre; // エイリアスをつける
import 'region_selection_modal.dart' as region; // エイリアスをつける

class FilterModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterModal({Key? key, required this.onApplyFilters}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5), // さらに薄いグレー
        title: const Text(
          '絞り込み検索',
          style: TextStyle(color: Colors.black), // 黒い文字色
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
      body: Container(
        color: Colors.white, // 背景を白に設定
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFilterSection(
                      'ジャンル',
                      filters['genre'].isEmpty
                          ? 'すべて'
                          : filters['genre'].join(', '),
                      _showGenreSelectionModal),
                  _buildFilterSection(
                      '地域',
                      filters['region'].isEmpty
                          ? 'すべて'
                          : filters['region'].join(', '),
                      _showRegionSelectionPage),
                  _buildDateSection(),
                  if (showStartCalendar) _buildCalendar(true),
                  if (showEndCalendar) _buildCalendar(false),
                ],
              ),
            ),
            _buildSearchButton(),
          ],
        ),
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
            color: Color(0xFFFF0059), // 色を変更
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
          // エイリアスを使って呼び出す
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
          // エイリアスを使って呼び出す
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
            color: Color(0xFFFF0059), // 色を変更
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateInput(
                '開始日',
                filters['startDate'],
                () => setState(() => showStartCalendar = !showStartCalendar),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('ー'),
            ),
            Expanded(
              child: _buildDateInput(
                '終了日',
                filters['endDate'],
                () => setState(() => showEndCalendar = !showEndCalendar),
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
        headerStyle: HeaderStyle(
          formatButtonVisible: false, // FormatButtonを非表示にする
          titleCentered: true, // タイトルを中央に配置する
        ));
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5, // ボタンの幅を50%に設定
        child: ElevatedButton(
          onPressed: () {
            widget.onApplyFilters(filters);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shadowColor: Colors.black.withOpacity(0.15), // 控えめなドロップシャドウ
            elevation: 10,
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
            '検索する',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
